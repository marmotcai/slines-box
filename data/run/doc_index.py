import os
from llama_index.readers.minio import MinioReader

'''
from datetime import timedelta
import tempfile
from typing import Any
from minio.error import S3Error

def safe_get_suffix(source):
    """安全获取文件后缀，支持字符串路径或ParseResult对象"""
    try:
        if not source:
            return ''
        return os.path.splitext(source.path if not isinstance(source, str) else source)[1]
    except:
        return ''
    
class MinioReaderEx(MinioReader):
    def __init__(self, *args: Any, **kwargs: Any):
        super().__init__(*args, **kwargs)
        from minio import Minio
        self.client = Minio(
            self.minio_endpoint,
            secure=self.minio_secure,
            cert_check=self.minio_cert_check,
            access_key=self.minio_access_key,
            secret_key=self.minio_secret_key,
            session_token=self.minio_session_token,
        )

    def count_in_bucket(self, bucket_name=None):
        """统计bucket中的对象数量"""
        bucket = bucket_name or getattr(self, 'bucket', None)
        if not bucket:
            raise ValueError("Bucket name not specified")
            
        try:
            return sum(1 for _ in self.client.list_objects(bucket, recursive=True))
        except S3Error as err:
            print(f"Error counting files in bucket {bucket}: {err}")
            return 0

    def get(self, source=None, target=None):
        """下载对象到本地文件"""
        if not target:
            target = tempfile.mktemp(prefix="sl_temp_", suffix=safe_get_suffix(source))
            
        try:
            self.client.fget_object(self.bucket, source, target)
            return target
        except Exception as e:
            print(str(e))
            return None

    def get_to_url(self, source=None, filename: str = None):
        """获取对象的预签名URL"""
        try:
            headers = {"response-content-disposition": f'attachment; filename="{filename}"'} if filename else None
            return self.client.get_presigned_url(
                "GET", self.bucket, source,
                expires=timedelta(days=1),
                response_headers=headers
            )
        except Exception as e:
            print(str(e))
            return None

    def put(self, source=None, key=None, bucket_name=None):
        bucket = bucket_name or getattr(self, 'bucket', None)
        if not bucket:
            raise ValueError("Bucket name not specified")
        
        try:            
            result = self.client.fput_object(bucket, key, source)
            print(f"Created object: {result.object_name}, etag: {result.etag}, version-id: {result.version_id}")
            return f"{key}"
            
        except Exception as e:
            print(str(e))
            return None

    def list_buckets(self):
        """列出所有bucket"""
        try:
            buckets = self.client.list_buckets()
            for bucket in buckets:
                print(f"{bucket.name}, {bucket.creation_date}")
            return buckets
        except S3Error as err:
            print(f"Error: {err}")
            return []
'''

reader = MinioReader(
    minio_endpoint="localhost:29000",
    bucket="documents",
    minio_access_key="BkYNchMeCo8Q6sRJjGAd",
    minio_secret_key="PNPZtrf7IJ1t6YEqYERIXUrEGseUgBWgZD6VoAIE",
    minio_secure = False,
    key = "安徽省促进科技成果转化条例.pdf"
)

tmp_file = reader.load_data()

from llama_index.embeddings.ollama import OllamaEmbedding

ollama_embedding = OllamaEmbedding(
    model_name="bge-m3:latest",
    base_url="http://10.213.84.13:20034",
    ollama_additional_kwargs={"mirostat": 0},
)

pass_embedding = ollama_embedding.get_text_embedding_batch(
    ["This is a passage!", "This is another passage"], show_progress=True
)
print(pass_embedding)

pass

