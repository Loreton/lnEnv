#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# updated by ...: Loreto Notarantonio
# Date .........: 30-11-2021 18.14.20
#
import  sys; sys.dont_write_bytecode = True
from    benedict import benedict
from pathlib import Path
import json, yaml
import os


# non modifica l'originale
def iterdict(d, newdict={}):
    def is_jsonable(x):
        try:
            json.dumps(x)
            return True
        except (Exception) as e:
            return False

    for k,v in d.items():
        if isinstance(v, dict):
            newdict[k]={}
            ptr=newdict[k]
            iterdict(v, ptr)
        else:
            # print (k,":",v)
            if is_jsonable(v):
                newdict[k]=v
            else:
                # v=str(v).replace('>', '').replace('<', '')
                # newdict[k]=f"no_serializzable: {v}"
                newdict[k]=str(v)
    return newdict


def writeYamlFile(*, file_out, d, title=None, indent=4, sort_keys=False, logger=None, replace=False):
    if logger:
        logger.debug(f'Writing file: {file_out}')
    yaml_data=dict_to_yaml(d, title=title, indent=indent, sort_keys=sort_keys)
    return _writeData(file_out=file_out, data=yaml_data, replace=replace)


def dict_to_yaml(d, title=None, indent=4, sort_keys=False):
    assert isinstance(d, dict)==True
    _d=iterdict(d, {})

    if title:
        _d={title: _d}

    json_data=json.dumps(_d, indent=indent, sort_keys=sort_keys)
    yaml_data=yaml.dump(yaml.load(json_data, Loader=yaml.FullLoader), indent=indent, sort_keys=sort_keys, default_flow_style=False)

    return yaml_data


def _writeData(*, file_out, data, replace=False):
    fileError=True
    # if not isinstance(file_out, PosixPath):
    file_out=Path(file_out)

    fWRITE=True

    if file_out.exists() and replace is False:
        fWRITE=False

    if isinstance(data, list):
        data='\n'.join(data)

    if fWRITE:
        os.makedirs(file_out.parent,  exist_ok=True)
        with open(file_out, "w") as f:
            f.write(f'{data}\n')
        fileError=False
    else:
        if logger:
            logger.warning('ERROR: file %s already exists.', file_out )

    return fileError


def jsonFileToYamlFile(filename):
    if filename.is_file():
        if filename.suffix=='.json':
            with open(filename) as f:
                my_dict = json.load(f)
            fileout=filename.with_suffix('.yaml')
            writeYamlFile(d=my_dict, file_out=fileout)
            print(f'file {fileout} has been created.')

    else:
        print(f'file: {filename} not found.')


def yamlFileToJsonFile(filename, replace=False):
    fileError=True
    if filename.is_file():
        if filename.suffix=='.yaml':
            with open(filename, 'r') as f:
                content=f.read() # single string

            _dict=yaml.load(content, Loader=yaml.FullLoader)

            # write to file
            fileout=filename.with_suffix('.json')
            # my_json=json.dumps(_dict, indent=4, sort_keys=True)
            my_json=json.dumps(_dict)
            fileError=_writeData(file_out=fileout, data=my_json, replace=replace)
            print(f'file {fileout} has been created.')

    else:
        print(f'file: {filename} not found.')

    return fileError


if __name__ == '__main__':
    filename=Path(sys.argv[1])
    if filename.is_file():
        if filename.suffix=='.json':
            jsonFileToYamlFile(filename)
            # data=benedict.from_json(str(filename))
            # data.to_json(filepath=f'./{filename}_LN.json') #

        elif filename.suffix=='.yaml':
            yamlFileToJsonFile(filename, replace=True)
