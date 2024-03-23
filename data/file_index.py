import os
import pickle
from datetime import datetime

class FileIndex:
    # a dictionary that maps the id of a gdelt download file (YYYYMMDDHHMMSS) to the file path
    
    def __init__(self):
        self.index = {}

    # add files of given directory to the index
    def index_files(self, folder_path):
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                # create id by replacing the last part of the filename, left is YYYYMMDDHHMMSS
                file_id = file.replace('.export.CSV', '').replace('.mentions.CSV', '')
                # create the path to the file
                file_path = os.path.join(root, file)
                # map file id to file path in file index
                self.index[file_id] = {'path': file_path}

    # save file index as pickle to disk
    def save_to(self, index_file_path):
        with open(index_file_path, 'wb') as file:
            pickle.dump(self.index, file)

    def load_from(self, index_file_path):
        if os.path.exists(index_file_path):
            with open(index_file_path, 'rb') as file:
                self.index = pickle.load(file)
        else:
            self.index = {}
        
        return self

    def has_id(self, id):
        return id in self.index
    
    def get_by_id(self, id):
        return self.index[id]

    def print_stats(self):

        print('FileIndex Stats:')
        print(f'The FileIndex contains {len(self.index)} files')

        year_month_index = {}

        print('Here is an overview of how many documents are stored in the FileIndex for each month:')
        for file_id in self.index.keys():
            date = datetime.strptime(file_id, '%Y%m%d%H%M%S')
            year_month = date.strftime('%Y/%m')
            year_month_index[year_month] = year_month_index.get(year_month, 0) + 1

            year_month_index = dict(sorted(year_month_index.items()))
        
        for year_month, count in year_month_index.items():
            print(f'{year_month}: {count}')


folder_path = './mentions-out'
index_file_path = './index.pkl'

# create file index
file_index = FileIndex()

# add files in dir to the file index
file_index.index_files(folder_path)

# Save the file index to disk
file_index.save_to(index_file_path)
