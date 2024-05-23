import pandas as pd
from imblearn.over_sampling import SMOTE
from scipy.stats import skew
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import precision_score, recall_score, f1_score, roc_auc_score, make_scorer
from catboost import CatBoostClassifier, Pool
import warnings
import mlflow

from sklearn.preprocessing import PowerTransformer, MinMaxScaler, LabelEncoder

warnings.filterwarnings('ignore')


def load_data(filepath):
    return pd.read_csv(filepath)


def preprocess_data(data):
    # Import the churn_data dataset
    clean_data = data.drop(data.columns[[0, 21, 22]], axis=1)

    # Normalize skewed numerical columns
    numerical_columns = clean_data.select_dtypes(include=['int', 'float']).columns
    skewed_cols = clean_data[numerical_columns].apply(lambda x: skew(x))
    skewed_cols = skewed_cols[skewed_cols > 0.5].index

    # Apply Yeo-Johnson power transform to skewed columns
    power_transformer = PowerTransformer(method='yeo-johnson')
    clean_data[skewed_cols] = power_transformer.fit_transform(clean_data[skewed_cols])

    # Standard scale the numerical columns
    scaler = MinMaxScaler()
    clean_data[numerical_columns] = scaler.fit_transform(clean_data[numerical_columns])

    # Count the number of '-1' values in each row and create a new column
    clean_data['Missing_Values_Count'] = (clean_data == -1).sum(axis=1)

    # Label encode 'Attrition_Flag'
    label_encoder = LabelEncoder()
    clean_data['Attrition_Flag'] = label_encoder.fit_transform(clean_data['Attrition_Flag'])

    # One-hot encode the categorical columns
    categorical_columns = clean_data.select_dtypes(include=['object']).columns
    clean_data = pd.get_dummies(clean_data, columns=categorical_columns)

    # Split the data into features and target variable
    X = clean_data.drop(columns=['Attrition_Flag'])
    y = clean_data['Attrition_Flag']

    # Apply SMOTE to handle class imbalance
    smote = SMOTE(random_state=42)
    X_resampled, y_resampled = smote.fit_resample(X, y)

    return X_resampled, y_resampled


def custom_scorer():
    scoring = {'precision': make_scorer(precision_score),
               'recall': make_scorer(recall_score),
               'f1': make_scorer(f1_score),
               'roc_auc': make_scorer(roc_auc_score, needs_proba=True)}
    return scoring


def grid_search(X_train, y_train, X_val, y_val):
    param_grid = {
        'iterations': [100 , 200],
        'depth': [3, 5, 7],
        'learning_rate': [0.01, 0.1],
        'l2_leaf_reg': [1, 3, 5]
    }

    catboost_model = CatBoostClassifier(verbose=0, random_seed=42)

    grid_search = GridSearchCV(estimator=catboost_model, param_grid=param_grid, scoring=custom_scorer(),
                               refit='roc_auc', cv=5, verbose=1)
    grid_search.fit(X_train, y_train)

    # Iterate through the results and print the metrics for each combination
    all_results = grid_search.cv_results_

    print('http://localhost:5000')
    mlflow.set_tracking_uri('http://localhost:5000')
    mlflow.set_experiment(experiment_name="catboost_churn_model")

    for i in range(len(all_results['params'])):
        with mlflow.start_run():
            mlflow.log_params(all_results['params'][i])
            mlflow.log_metric("Mean precision", all_results['mean_test_precision'][i])
            mlflow.log_metric("Mean recall", all_results['mean_test_recall'][i])
            mlflow.log_metric("Mean f1", all_results['mean_test_f1'][i])
            mlflow.log_metric("Mean ROC-AUC", all_results['mean_test_roc_auc'][i])

            print(f"Parameters: {all_results['params'][i]}")
            print(f"Mean precision: {all_results['mean_test_precision'][i]:.4f}")
            print(f"Mean recall: {all_results['mean_test_recall'][i]:.4f}")
            print(f"Mean f1: {all_results['mean_test_f1'][i]:.4f}")
            print(f"Mean ROC-AUC: {all_results['mean_test_roc_auc'][i]:.4f}")
            print("=" * 60)

    # breakpoint()

    return grid_search.best_estimator_


def evaluate_model(model, X, y, dataset_type="dataset"):
    predictions = model.predict(X)
    proba = model.predict_proba(X)[:, 1]

    precision = precision_score(y, predictions)
    recall = recall_score(y, predictions)
    f1 = f1_score(y, predictions)
    roc = roc_auc_score(y, proba)

    print(f"{dataset_type} Precision: {precision:.4f}")
    print(f"{dataset_type} Recall: {recall:.4f}")
    print(f"{dataset_type} F1-Score: {f1:.4f}")
    print(f"{dataset_type} ROC-AUC: {roc:.4f}")

    return precision, recall, f1, roc


def main():
    # Load data
    filepath = '/home/gg/PycharmProjects/churning2/data/raw/bank_churners.csv'
    data = load_data(filepath)

    # Preprocess data
    X, y = preprocess_data(data)

    # Splitting data into train, validation, and test sets
    X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=0.3, random_state=42)
    X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)

    # Perform grid search and get the best model
    model = grid_search(X_train, y_train, X_val, y_val)

    # Evaluate model on training data
    print("\nTraining Metrics:")
    evaluate_model(model, X_train, y_train, "Training")

    # Evaluate model on validation data
    print("\nValidation Metrics:")
    evaluate_model(model, X_val, y_val, "Validation")

    # Evaluate model on test data
    print("\nTest Metrics:")
    evaluate_model(model, X_test, y_test, "Test")


if __name__ == "__main__":
    main()
