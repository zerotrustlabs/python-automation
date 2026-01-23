"""Module providing a function pautomating cicd flow and file watcher for docker events."""
# import sys
from pathlib import Path
# from time import perf_counter
from typing import Optional
from datetime import datetime, timedelta
from schedule import every, repeat, run_pending

# import os

def get_files(file_type:str, path: Optional[Path] = None):
    """Create a python script that can loop through flile and filter the for only json fies"""
    # start_time=perf_counter()
    current = Path.cwd if path is None else Path(path)
    try:
        for dir_path in current.iterdir():
            if dir_path.is_dir():

                print(dir_path)
                print("--"*10)
            # print([x.relative_to(dir_path) for x in dir_path.rglob('*.json') if x.is_dir()])

                for file_path in dir_path.rglob(file_type):
                    try:
                        if file_path.is_file():
                            print(file_path.relative_to(dir_path))
                    except (PermissionError, OSError) as e:
                        print(f'NO PERM {e}')
                        continue
    except (PermissionError, OSError) as e:
        print(f'Dir error {dir_path} ,  handled {e}')

    # end_time=perf_counter()

    # print(f'start time: {start_time} \nend time: {end_time} \ntime diff: {end_time - start_time}')
    return file_path

@repeat(every(1).minutes,get_files,"*.py",Path.cwd())
def watcher(func,pattern:str, dir):
    """Function file watcher runs continuously to ccheck modified or updated file changes """
    file = func(pattern, dir)
    current_time = datetime.now()
    # formatted=current_time.strftime("%H:%M:%S")
    timediff = timedelta(seconds=15)

    future_time = current_time + timediff
    # elapsed_formatted = elapsed_time.strftime("%H:%M:%S")

    while datetime.now() < future_time:

        print(current_time.strftime("%H:%M:%S"))
        print("elapse")
    return file


    # time.sleep(1)
# end def

def main():
    """ Main caller function """
    path = Path.cwd()
    pattern="*.py"
    # get_files('*.py',path)
    watcher(get_files,pattern,path)
    while True:
        run_pending()



if __name__=='__main__':
    main()



# import datetime
# import pathlib

# # create a file path
# path = pathlib.Path(r'myfile.txt')

# # get modification time
# timestamp = path.stat().st_mtime

# # convert time to dd-mm-yyyy hh:mm:ss
# m_time = datetime.datetime.fromtimestamp(timestamp)
# print('Modified Date/Time:', m_time)

# # get creation time on windows
# current_timestamp = path.stat().st_ctime
# c_time = datetime.datetime.fromtimestamp(current_timestamp)
# print('Created Date/Time on:', c_time)