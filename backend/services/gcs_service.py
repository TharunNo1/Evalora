import os
from tempfile import NamedTemporaryFile
from google.cloud import storage
from google.api_core.exceptions import GoogleAPIError, NotFound


class GCSService:
    """Google Cloud Storage service wrapper with error handling."""

    def __init__(self, bucket_name: str = None):
        bucket_name = bucket_name or os.getenv("BUCKET_NAME")
        if not bucket_name:
            raise ValueError("❌ BUCKET_NAME must be provided either as arg or env var.")

        try:
            self.client = storage.Client()
            self.bucket = self.client.bucket(bucket_name)
            self.bucket_name = bucket_name
        except GoogleAPIError as e:
            raise RuntimeError(f"❌ Failed to initialize GCS client: {e}")

    def list_files(self):
        """List all file names in the bucket."""
        try:
            return [blob.name for blob in self.bucket.list_blobs()]
        except GoogleAPIError as e:
            print(f"❌ Error listing files: {e}")
            return []

    def upload_file(self, file_obj, filename: str, content_type: str = None) -> bool:
        """
        Upload a file object to GCS.
        - file_obj: file-like object (open file, BytesIO, etc.)
        - filename: destination name in GCS
        """
        try:
            blob = self.bucket.blob(filename)
            blob.upload_from_file(file_obj, content_type=content_type)
            return True
        except GoogleAPIError as e:
            print(f"❌ Error uploading file '{filename}': {e}")
            return False

    def download_file(self, filename: str) -> str | None:
        """
        Download file from GCS into a temporary local file.
        Returns local file path if successful, else None.
        """
        try:
            blob = self.bucket.blob(filename)
            if not blob.exists():
                return None

            temp_file = NamedTemporaryFile(delete=False)
            blob.download_to_filename(temp_file.name)
            return temp_file.name
        except NotFound:
            return None
        except GoogleAPIError as e:
            print(f"❌ Error downloading file '{filename}': {e}")
            return None

    def delete_file(self, filename: str) -> bool:
        """Delete a file from GCS."""
        try:
            blob = self.bucket.blob(filename)
            blob.delete()
            return True
        except NotFound:
            print(f"⚠️ File '{filename}' not found in bucket.")
            return False
        except GoogleAPIError as e:
            print(f"❌ Error deleting file '{filename}': {e}")
            return False
