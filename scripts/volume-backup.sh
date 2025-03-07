#!/bin/bash

tar -czvf data.tar.gz ${DATA_DIR}
tar -czvf venv.tar.gz ${VENV_DIR}
tar -czvf hanlp.tar.gz ${HANLP_DIR}
tar -czvf paddlenlp.tar.gz ${PADDLENLP_DIR}
tar -czvf swofd_lib.tar.gz ${SWOFD_LIB_DIR}
tar -czvf nltk_data.tar.gz ${NLTK_DATA_DIR}