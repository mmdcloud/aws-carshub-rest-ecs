import json
import boto3
import pymysql
import os

s3 = boto3.client('s3', region_name='us-east-1')

# Function to get secrets from AWS Secrets Manager
def get_secret():
    secret_name = os.environ['SECRET_NAME']
    region_name = os.environ['REGION']

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client('secretsmanager', region_name=region_name)

    # Retrieve the secret
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(get_secret_value_response['SecretString'])
    
    return secret['username'], secret['password']

# Function to create a database connection
def get_db_connection(username, password):
    return pymysql.connect(
        host=os.environ['DB_HOST'],
        user=username,
        password=password,
        database=os.environ['DB_NAME']
    )

def insertQuery(connection,path,metadata):
    with connection.cursor() as cursor:
        print("path")
        print(path)        
        sql = "INSERT INTO InventoryImages (inventoryId, path, type, description) VALUES (%s, %s, %s, %s)"
        values = (metadata["inventoryid"], path,metadata["typeofdocument"],metadata["descriptionofdocument"])
        cursor.execute(sql, values)
        connection.commit()

def lambda_handler(event, context):
    username, password = get_secret()
    connection = get_db_connection(username, password)    
    table_name = "InventoryImages"
    bucket = "carshubmediabucket"
    filename = json.loads(event['Records'][0]['body'])['Records'][0]['s3']['object']['key']    
    try:
        print("before metadata")
        response = s3.head_object(Bucket=bucket, Key=filename)
        
        # Extract the metadata from the response
        metadata = response.get('Metadata', {}) 
                    
        insertQuery(connection,filename,metadata)                
        return {
            'statusCode': 200,
            'body': 'Record inserted successfully'
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': str(e)
        }
    finally:
        connection.close()