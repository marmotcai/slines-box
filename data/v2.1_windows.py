
import os
import copy
import json

from packaging import version

from slines.utils.logging import init_logger
from slines.snow_id import get_snow_id

from slinesplug.plugins.data_storage.storage import StorageClient
from slines.utils.utils import get_str_hash

from slinesplug.plugins.elasticsearch_manager.builtin.esmanager.esmanager import ESManager
from slinesplug.plugins.elasticsearch_manager.builtin.esmanager.data_collection import dc_index_name, dc_document, dc_paragraph
from urllib.parse import urlparse

from pymongo import MongoClient

from datetime import datetime

DEBUG = False
TEST = False

logger = init_logger(is_debug = DEBUG)

logger.info("This is an info message.")
logger.warning("This is a warning message.")
logger.error("This is an error message.")

###################################################################################

parent_path = f"Y:/电子公文库文档数据/分类前/公司爬取数据" 
assert os.path.exists(parent_path), f"Path does not exist: {parent_path}"

###################################################################################

try:
    uid = get_snow_id()
    logger.info(f"Successfully generated snowflake ID: {uid}")
except Exception as e:
    logger.error(f"Failed to generate snowflake ID: {e}")

print(uid)

###################################################################################

mongo_url = r"mongodb://root:Suwell123@172.16.32.201:27017/"

def mongo_query(mongo_url = None, collection = None, query = {}):    
    try:
        if (collection is None):
            mongo_client = MongoClient(mongo_url)
        
            db = mongo_client['crawler_file']
            collection = db['file_info']
        
            result = collection.distinct("SiteName", filter=query)
        else:
            result = collection.find(query)

    except Exception as e:
        logger.error(f"An error occurred: {e}")
        return None, []

    return collection, result

query = {"SiteName": {"$ne": None}}
collection, site_names = mongo_query(mongo_url = mongo_url, query = query)

logger.info(f"站点总数: {len(site_names)}, 站点名称: {site_names}")

###################################################################################

minio_url = r"s3://Ui8HWTa4L9Ow7RU9zS2E:M8PLO52GH6NNJlQAStEV2NdT71pWbcEeDzdjTcqM@172.16.32.54:9000/swdocument"

if DEBUG:
    minio_url = minio_url + "-test"

try:
    target_client = StorageClient.get_client(minio_url)
    assert target_client is not None
    logger.info("Successfully created StorageClient.")
except Exception as e:
    logger.error(f"Failed to create StorageClient: {e}")

def upload_file(webSite, filePath, fileId, target_path = minio_url, os_id = None):
    if (os_id is not None):
        logger.info(f"File already uploaded: {os_id}")
        return os_id

    file_path = filePath.replace('\\', '/')
    full_path = os.path.join(parent_path, file_path)

    result = None

    if not os.path.exists(full_path):
        filename = os.path.basename(file_path)
        full_path = os.path.join(parent_path, file_path.replace(filename, ""), filename.strip())
                    
    if os.path.exists(full_path):
        try:
            object_name = webSite + '/' + get_str_hash(file_path)[:10] + '/' +str(fileId)

            logger.info(f"upload file: {full_path} to {target_path} as {object_name}")
            result = target_client.put(source=full_path, target=target_path, key=object_name)
            logger.info(f"File uploaded successfully: {full_path} to {target_path} as {object_name}")
        except Exception as e:
            logger.error(f"Failed to upload file: {full_path}. Error: {str(e)}")
    else:
        result = f"File does not exist: {full_path}"
        logger.error(result)
        
    return result

###################################################################################

es_url = r"http://elastic:Suwell123@172.16.32.54:9200"

if DEBUG:
    dc_index_name = dc_index_name + "-test"

print(dc_index_name)

parsed = urlparse(es_url)
host = parsed.scheme + "://" + parsed.hostname + ":" + str(parsed.port)

try:
    es = ESManager(host=host, username=parsed.username, password=parsed.password)
except Exception as e:
    logger.error(f"Failed to create index: {e}")


def updata_es(es, document: dict, id: str, index_name = None):
    es_result = es.add_document(document, id = str(document["fileId"]), index_name=dc_index_name)
    es_id = None
    if (es_result is not None):
        es_id = es_result.get("_id", None)
    return es_id

###################################################################################

def get_path(filename, parent_path=parent_path):
    filename = filename.replace('\\', '/')
    return filename # os.path.join(parent_path, filename)

def get_file_id(FileId):
    if FileId is None:
        return get_snow_id()
    return FileId

def get_status(GeneratedJson=None):
    if GeneratedJson is None:
        return 0
    return 1

def get_accessoryList(filename = "", Accessory=[]):
    filepath = os.path.dirname(filename.replace('\\', '/'))
    for i in range(len(Accessory)):
        Accessory[i] = os.path.join(filepath, Accessory[i])
    
    return Accessory

def get_attachmentList(Attachment=[]):
    if not Attachment or isinstance(Attachment, bool):
        return []
    
    if isinstance(Attachment, dict):
        return [Attachment]
    
    return Attachment
    
def convert_date_to_timestamp(date_str):
    if date_str is None:
        return date_str

    date_formats = [
        "%Y-%m-%dT%H:%M:%S.%f",
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%d %H:%M:%S",
        "%Y/%m/%d %H:%M:%S",
        "%d-%m-%Y",
        "%m/%d/%Y",
        "%Y.%m.%d",
        # Add more formats as needed
    ]

    for fmt in date_formats:
        try:
            dt = datetime.strptime(date_str, fmt)
            timestamp = int(dt.timestamp() * 1000)  # Convert to milliseconds
            return timestamp
        except ValueError:
            continue

    logger.error(f"Unrecognized date format: {date_str}")
    return None
    
migrations_v2 = {
    "ver": "2",
    "iteration_ver": "2.1.1.9.1",
    "iteration_description": "更新V2格式数据",
    "changes": {
        "modified": {
            "fileId": {
                "type": "string",
                "description": "文件唯一ID",
                "action": {
                    "type": "function",
                    "entrypoint": get_file_id,
                    "kwargs": {
                        "FileId": "FileId"
                    }
                }
            },
            "filePath": {
                "type": "string",
                "description": "NAS路径",
                "action": {
                    "type": "function",
                    "entrypoint": get_path,
                    "kwargs": {
                        "filename": "FileName"
                    }
                }
            },
            "webSite": {
                "type": "string",
                "description": "网站",
                "action": {
                    "type": "transfer",
                    "source": "SiteName"
                }
            },
            "os_id": {
                "type": "string",
                "description": "上传到对象存储",
                "action": {
                    "type": "function",
                    "entrypoint": upload_file,
                    "kwargs": {
                        "filePath": "filePath",
                        "webSite": "webSite",
                        "fileId": "fileId",
                        "os_id": "os_id"
                    }
                }
            },
            "status": {
                "type": "string",
                "description": "入库状态",
                "action": {
                    "type": "function",
                    "entrypoint": get_status,
                    "kwargs": {
                        "GeneratedJson": "GeneratedJson"
                    }
                }
            },
            "isFormatted": {
                "type": "string",
                "description": "是否格式化",
                "action": {
                    "type": "function",
                    "entrypoint": get_status,
                    "kwargs": {
                        "GeneratedJson": "GeneratedJson"
                    }
                }
            },
            "oldID": {
                "type": "string",
                "description": "老的ID",
                "action": {
                    "type": "transfer",
                    "source": "_id"
                }
            },
            "srcUrl": {
                "type": "string",
                "description": "原始链接",
                "action": {
                    "type": "transfer",
                    "source": "Url"
                }
            },
            "categoryList": {
                "type": "string",
                "description": "类别列表",
                "action": {
                    "type": "transfer",
                    "source": "Category"
                }
            },
            "title": {
                "type": "string",
                "description": "标题",
                "action": {
                    "type": "transfer",
                    "source": "Title"
                }
            },
            "releaseDate": {
                "type": "string",
                "description": "发布日期|公布日期",
                "action": {
                    "type": "function",
                    "entrypoint": convert_date_to_timestamp,
                    "kwargs": {
                        "date_str": "FileDate"
                    }
                }
            },
            "keywordList": {
                "type": "string",
                "description": "关键词列表",
                "action": {
                    "type": "transfer",
                    "source": "Keywords"
                }
            },
            "issuer": {
                "type": "string",
                "description": "发文机关",
                "action": {
                    "type": "transfer",
                    "source": "Issuer"
                }
            },
            "issueNo": {
                "type": "string",
                "description": "发文字号",
                "action": {
                    "type": "transfer",
                    "source": "FileNo"
                }
            },
            "crawlTime": {
                "type": "string",
                "description": "爬取时间",
                "action": {
                    "type": "function",
                    "entrypoint": convert_date_to_timestamp,
                    "kwargs": {
                        "date_str": "CrawlTime"
                    }
                }
            },
            "repositoryList": {
                "type": "string",
                "description": "文档类型",
                "action": {
                    "type": "transfer",
                    "source": "type_name"
                }
            },
            "levelTypeList": {
                "type": "string",
                "description": "发文机关标签",
                "action": {
                    "type": "transfer",
                    "source": "level_type_list"
                }
            },
            "accessoryList": {
                "type": "string",
                "description": "附件列表",
                "action": {
                    "type": "function",
                    "entrypoint": get_accessoryList,
                    "kwargs": {
                        "Accessory": "Accessory",
                        "filename": "FileName"
                    }
                }
            },
            "attachmentList": {
                "type": "string",
                "description": "附件列表",
                "action": {
                    "type": "function",
                    "entrypoint": get_attachmentList,
                    "kwargs": {
                        "Attachment": "Attachment",
                    }
                }
            }
        },
        "removed": {
            "FileId": {
                "type": "string",
                "description": "FileId"
            },
            "SiteName": {
                "type": "string",
                "description": "SiteName"
            },
            "Accessory": {
                "type": "string",
                "description": "Accessory"
            },
            "FileDate": {
                "type": "string",
                "description": "FileDate"
            },
            "CrawlTime": {
                "type": "string",
                "description": "CrawlTime"
            },
            "Attachment": {
                "type": "string",
                "description": "Attachment"
            },
            "Status": {
                "type": "string",
                "description": "删除旧的Status字段"
            },
            "GeneratedJson": {
                "type": "string",
                "description": "删除旧的GeneratedJson字段"
            },
            "FileName": {
                "type": "string",
                "description": "FileName"
            },
            "verson": {
                "type": "string",
                "description": "verson"
            },
            "Batch": {
                "type": "string",
                "description": "Batch"
            },
        }
    }
}

class MigrationProcessor:

    @staticmethod
    def migrations(data, migrations):
        if migrations is None:
            return None

        samples = data.copy()
        logger.info(f'Processing file: {samples.get("FileName")}')

        modifieds = migrations.get("modified")
        if modifieds is not None:    
            for key, value in modifieds.items():
                action = value.get("action")
                description = value.get("description")

                if action.get("type") == "transfer":
                    source = action.get("source")
                    old_value = samples.get(source)

                    samples[key] = samples.pop(source, None)

                elif action.get("type") == "function":
                    entrypoint = action.get("entrypoint")
                    kwargs = action.get("kwargs").copy()

                    for k, v in kwargs.items():                    
                        if isinstance(v, str) and v in samples:
                            kwargs[k] = samples.get(v, None)
                        else:
                            kwargs[k] = None

                    old_value = copy.deepcopy(kwargs)
                    samples[key] = entrypoint(**kwargs)

                new_value = samples[key]
                logger.info(f"Executing modified script {key} {old_value} -> {new_value}")

        removeds = migrations.get("removed")
        if removeds is not None:    
            for key, value in removeds.items():
                if DEBUG:
                    logger.info(f"Executing remove script: {key} - {value.get('description')}")
                samples.pop(key, None)

        return samples

    def __init__(self, migrations_info):
        self.migrations_info = {}
        if isinstance(migrations_info, dict):
            self.migrations_info = migrations_info
        elif isinstance(migrations_info, str):
            if os.path.isfile(migrations_info):
                if migrations_info.lower().endswith('.json'):
                    with open(migrations_info, 'r', encoding='utf-8') as file:
                        self.migrations_info = json.load(file)
                else:
                    logger.error("Unsupported file format. Only JSON files are supported.")
            else:
                try:
                    self.migrations_info = json.loads(migrations_info)
                except json.JSONDecodeError:
                    logger.error("Invalid JSON string provided for migrations_info.")
        else:
            logger.error("migrations_info must be a dict, a JSON string, or a file path.")

    def process(self, data):
        return MigrationProcessor.migrations(data, self.migrations_info.get("changes"))

if TEST:
    # test_data = {'_id': '665057384726e81ab0707ab9', 'Url': 'http://ny.sanya.gov.cn/nyjsite/bmwjxx/202405/c6807a11a1f24dc6832406f74d8cbd74.shtml', 'Title': '三亚农业产业投资指南', 'FileName': '三亚市人民政府\\政策\\政府信息公开专栏\\政策文件\\部门文件\\三亚农业产业投资指南.docx', 'RawFile': 'None', 'SiteName': '三亚市人民政府', 'Category': ['政策', '政府信息公开专栏', '政策文件', '部门文件'], 'CrawlTime': '2024-05-24T17:00:33.343000', 'FileDate': '2024.05.23', 'Keywords': [], 'Issuer': '三亚市农业农村局', 'FileNo': '', 'Accessory': ['三亚农业产业投资指南（印刷版）.pdf'], 'Stored': False, 'verson': '0.1', 'Batch': '1716541233', 'Extend': {'regulation': {'source': '三亚市农业农村局', 'time': '2024.05.23'}}, 'WrittenDate': '2024.05.23', 'Status': '有效', 'FileId': 105357478397830}
    test_data = {'_id': '6650615d4726e81ab0707f92', 'Url': 'http://hrss.sanya.gov.cn/rsjsite/bmwjxx/202212/7b813c5788524a218ac24b5578e7a820.shtml', 'Title': '三亚市人力资源和社会保障局关于开展2022年度劳动保障书面审查工作的通知', 'FileName': '三亚市人民政府\\政策\\政府信息公开专栏\\政策文件\\部门文件\\劳动、人事、监察;\\三亚市人力资源和社会保障局关于开展2022年度劳动保障书面审查工作的通知.docx', 'RawFile': 'None', 'SiteName': '三亚市人民政府', 'Category': ['政策', '政府信息公开专栏', '政策文件', '部门文件', '劳动、人事、监察;'], 'CrawlTime': '2024-05-24T17:43:54.821000', 'FileDate': '2022.12.23', 'Keywords': [], 'Issuer': '三亚市人力资源和社会保障局', 'FileNo': '三人社发〔2022〕146号', 'Accessory': ['1.海南省用人单位劳动保障年度书面审查报审表.doc', '2.书面审查报审表填报说明.doc', '3.用人单位职工名册.doc', '4.市、区人力资源和社会保障局联系人及联系方式.docx'], 'Stored': False, 'verson': '0.1', 'Batch': '1716543834', 'Extend': {'regulation': {'source': '三亚市人力资源和社会保障局', 'time': '2022.12.23'}, 'Policy': {'Type': ['省市级', '海南省', '三亚市'], 'Issuer': '三亚市人力资源和社会保障局', 'Theme': [], 'FileFate': '2022.12.23', 'Genre': '通知'}}, 'WrittenDate': '2022.12.21', 'Status': '有效', 'FileId': 105368115321670, 'Attachment': True}

    print(f"old: {test_data}")

    mp = MigrationProcessor(migrations_v2)
    new_data = mp.process(test_data)

    print(f"new: {new_data}")

    result = updata_es(es, new_data, id = new_data["fileId"], index_name=dc_index_name)
    print(result)

###################################################################################

# macos: mount_smbfs 'smb://bot:bot123456@172.16.32.217/Test' ~/remote_data ## umount ~/remote_data
# linux：mount -t cifs bot:bot123456@172.16.32.217/Test ~/remote_data -o nobrowse

site_number = 0
processed_count = 0

logger.info(f"站点总数: {len(site_names)}")
if DEBUG:
    site_names = [site_names[0]]

success_count = 0
failure_count = 0

def serialize_document(doc):
    if isinstance(doc, dict):
        return {key: serialize_document(value) for key, value in doc.items()}
    elif isinstance(doc, list):
        return [serialize_document(item) for item in doc]
    elif isinstance(doc, (int, float, str, bool)):
        return doc
    elif hasattr(doc, 'isoformat'):
        return doc.isoformat()
    elif hasattr(doc, 'binary'):
        return doc.binary.hex()
    else:
        return str(doc)   

def version_analysis(existing_data, new_data):
    existing_version = version.parse(existing_data.get('iteration_ver', '0'))
    new_version = version.parse(migrations_data.get('iteration_ver', '0'))
    if new_version <= existing_version:
        logger.info(f"Skipping migration for {full_path}: existing version {existing_version} >= new version {new_version}")
        return False
    return True

def docdata_processor(doc_data, migrations_data):
    _data = MigrationProcessor.migrations(doc_data, migrations_data["changes"])
    if _data is None:
        logger.error(f"Failed to process data for {doc_data.get('fileId')}")

    _data["migrations_ver"] = ver
    _data["iteration_ver"] = migrations_data.get('iteration_ver', ver)
    _data["iteration_description"] = migrations_data.get('iteration_description', ver)

    es_id = updata_es(es, _data, str(_data["fileId"]), dc_index_name)
    if es_id is None:
        logger.error(f"Failed to update ES for {_data.get('fileId')}")

    new_doc_data = {
            "file_id": doc_data.get('FileId', None),
            "es_id": es_id,
            "os_id": _data.get("os_id", None),
            "src_url": _data.get('srcUrl', ''),
            "file_path": _data.get('filePath', ''),
            "ver": ver,
            "Ver1": doc_data,
            f"Ver{ver}": _data
        }
    return new_doc_data

for site_name in site_names:

    if DEBUG and site_number > 1:
        break

    site_number += 1
    try:
        if site_name is None:
            continue

        query = {"SiteName": site_name}
        _, site_data = mongo_query(collection = collection, query = query)
        site_data = list(site_data)

        logger.info(f"开始转换: {site_name} ({site_number}/{len(site_names)}) 数据量: {len(site_data)} ")
        
        success_count = 0
        failure_count = 0
        
        number = 0
        for data in site_data:
            if DEBUG and number > 100:
                break
            number = number + 1
            
            try:
                doc_data = serialize_document(data)
                File_Name = doc_data.get('FileName', '').replace('\\', '/')
                if not File_Name or File_Name == '':
                    continue

                full_path = os.path.join(parent_path, File_Name)
                if os.path.exists(full_path):
                    if DEBUG:
                        logger.info(f"File exists: {full_path}")
                else:
                    filename = os.path.basename(File_Name)
                    full_path = os.path.join(parent_path, File_Name.replace(filename, ""), filename.strip())
                    if not os.path.exists(full_path):
                        logger.error(f"File does not exist: {full_path}")
                        continue

                migrations_data = migrations_v2.copy()
                ver = migrations_data.get('ver', '2')
                json_path = full_path + '.json'
                
                if os.path.exists(json_path):
                    continue

                    try:
                        with open(json_path, 'r') as f:
                            existing_data = json.load(f)
                        have_update = version_analysis(existing_data, migrations_data)
                        if not have_update:
                            continue
                        doc_data["os_id"] = existing_data.get('os_id', None)
                    except json.JSONDecodeError as e:
                        logger.error(f"JSON decode error for {json_path}: {e}")
                    except Exception as e:
                        logger.error(f"Error processing JSON for {json_path}: {e}")
                else:
                    logger.info(f"JSON file does not exist, creating new one: {json_path}")

                new_doc_data = docdata_processor(doc_data, migrations_data)
                logger.info(f'file_id: {new_doc_data.get("file_id")}, file_path: {new_doc_data.get("file_path")}')
                
                with open(json_path, 'w', encoding='utf-8') as json_file:
                    json.dump(new_doc_data, json_file, ensure_ascii=False, indent=4)
                                
                processed_count += 1
                success_count += 1

            except Exception as e:
                logger.error(f"An error occurred: {e}")
                failure_count += 1

            if processed_count % 1000 == 0:
                print(f"Processed {processed_count} files, Success: {success_count}, Failure: {failure_count}")

    except Exception as e:
        logger.error(f"Errors occurred: {e}")

    print(f"Processing complete. Total processed: {processed_count}, Success: {success_count}, Failure: {failure_count}")