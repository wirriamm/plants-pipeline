# Module Header ################################################################
import sys
from os.path import realpath, dirname
import re

if __name__ == '__main__':
    abspath = realpath(dirname(__file__))
    parent_module = re.search('^(.*plants-pipeline)', abspath).group()
    sys.path.insert(0, parent_module)
################################################################################

import os
import argparse
import pandas as pd
import pdb
# Relative imports
from config.constants import DATA_PATH
import helpers
import process_fastq as proc
import linear_download as linear

parser = argparse.ArgumentParser(description = 'This script despatches runids to download.py to run the ascp download and kallisto quantification for each Run ID in parallel.', epilog = 'By Mutwil Lab')
parser.add_argument('-s', '--species', nargs=1, metavar='species_alias',
                    help='Enter the species alias to be downloaded. For instance, Arabidopsis thaliana\'s species alias would be \'Ath\'.',
                    dest='spe', type=str, required=True)
parser.add_argument('-c', '--cds', nargs=1, metavar='cds_filename',
                    help='Enter the file name of the cds .fasta file to use. Do not include the full path, just the filename. It is expected that cds file is places in pipeline-data/download/cds directory.',
                    dest='cds_filename', type=str, required=True)
parser.add_argument('-m', '--method', nargs=1, metavar='download_method',
                    help="This script allows for download methods: 'ascp' or 'curl'.",
                    dest='download_method', type=str, required=True)
parser.add_argument('-l', '--linearmode', action='store_true', default=False, required=False, dest='linearmode', help="Include this optional tag if download is to be in linear mode, else default will be parallel processes.")
args = parser.parse_args()
spe = args.spe[0].capitalize()
cds_path = f"{DATA_PATH}/download/cds/{args.cds_filename[0]}"
idx_path = f"{DATA_PATH}/download/idx/{spe}.idx"
runtable_path = helpers.build_runtable_path(spe)
download_method = args.download_method[0].lower()
linearmode = args.linearmode

assert os.path.exists(runtable_path), f"The runtable for {spe} is not in pipeline-data/preprocess/out/sra-runtables."

if download_method == 'ascp':
    curl_stream = False
elif download_method == 'curl':
    curl_stream = True
else:
    raise Exception("-method specified is invalid. Only accepts 'ascp' or 'curl'")

# TODO: Make it robust to SRA inconsistent header names
runs_df = helpers.read_runtable(spe, runtable_path)
runids = runs_df['Run'].iloc[::300][:10]

if __name__ == '__main__':
    if not os.path.exists(idx_path):
        runtime, exit_code, _ = proc.kallisto_index(idx_path=idx_path, cds_path=cds_path)
    linear.process_batch(runids, idx_path, spe, curl=curl_stream, linear=linearmode)