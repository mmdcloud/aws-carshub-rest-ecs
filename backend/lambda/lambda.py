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

def check_table_exists(connection, table_name):
    with connection.cursor() as cursor:
        # SQL query to check if the table exists
        sql = """
        SELECT COUNT(*)
        FROM information_schema.tables 
        WHERE table_schema = %s 
        AND table_name = %s
        """
        cursor.execute(sql, (connection.db.decode(), table_name))
        result = cursor.fetchone()
        return result[0] > 0

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
    print("event")
    print(event)
    table_name = "InventoryImages"
    bucket = "theplayer007-vehicle-images"
    filename = event['Records'][0]['s3']['object']['key']    
    try:
        print("before metadata")
        response = s3.head_object(Bucket=bucket, Key=filename)
        
        # Extract the metadata from the response
        metadata = response.get('Metadata', {}) 
        print("metadata")
        print(metadata["inventoryid"]);
        print(metadata["typeofdocument"]);
        print(metadata["descriptionofdocument"]);
        if check_table_exists(connection, table_name):
            insertQuery(connection,event['Records'][0]['s3']['object']['key'],metadata)
        else:
            with connection.cursor() as cursor:
                sql = """
                    CREATE TABLE IF NOT EXISTS InventoryImages (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    inventoryId VARCHAR(255) NOT NULL,
                    path VARCHAR(255) NOT NULL,
                    type VARCHAR(255) NOT NULL,
                    description VARCHAR(255) NOT NULL
                )
                """
                cursor.execute(sql)
                connection.commit()

            insertQuery(connection,event['Records'][0]['s3']['object']['key'],metadata)

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
