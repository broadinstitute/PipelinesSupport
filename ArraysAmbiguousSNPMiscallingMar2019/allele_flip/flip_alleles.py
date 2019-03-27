#!/bin/python
import argparse
import pandas as pd

def __main__(bim_in, bim_out, snps_list, log):

    # step 1: import bim data
    bim_data = pd.read_csv(bim_in,
                           sep="\s+",
                           header=None,
                           names=["CHR", "RSID", "DIST (Morgan)", "DIST (BP)", "A1", "A2"],
                           dtype={'CHR': str, 'RSID': str, 'DIST (Morgan)': int, 'DIST (BP)': int, "A1": str, "A2": str})

    # step 2: import SNPs list
    snps = pd.read_csv(snps_list, sep='\s+', comment='@',
                       header=None, names=['CHR', 'START', 'END', 'STRAND', 'RSID'])

    # step 3: split multiple SNPs row
    snps = snps['RSID'].str.split('|').apply(pd.Series, 1).stack()
    snps.index = snps.index.droplevel(-1)
    snps.name = 'RSID'

    # step 5: convert it to a list
    snps = snps.tolist()

    # step 6: count number of SNPs in the list
    n_snps = len(snps)

    # step 7: count number of SNPs matched
    n_snps_matched = sum(bim_data['RSID'].isin(snps))

    # step 8: flip alleles
    tmp1 = bim_data.loc[bim_data['RSID'].isin(snps), 'A2']
    tmp2 = bim_data.loc[bim_data['RSID'].isin(snps), 'A1']
    bim_data.loc[bim_data['RSID'].isin(snps), 'A1'] = tmp1
    bim_data.loc[bim_data['RSID'].isin(snps), 'A2'] = tmp2

    # step 9: export bim
    bim_data.to_csv(bim_out, sep=' ', header=False, index=False)

    # step 10: save log_info to log if --log is specified, otherwise output log_info to stdout
    log_info = 'python 08.-flip_alleles.py \n' \
               '--list %s \n' \
               '--bim-in %s \n' \
               '--bim-out %s \n\n' \
               'log output: \n' \
               'number of SNPs in interval list to flip alleles: %d\n' \
               'number of SNPs successfully matched to map file: %d\n' \
               'updated map file is here: %s\n'\
               'Note that the first XXX should equal the second XXX if all went well.\n'% (snps_list, bim_in, bim_out, n_snps, n_snps_matched, bim_out)

    if log is None:
        print(log_info)
    else:
        log_handler = open(log, 'w')
        log_handler.write(log_info)
        log_handler.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--bim-in', action='store', dest='bim_in', required=True)
    parser.add_argument('--bim-out', action='store', dest='bim_out', required=True)
    parser.add_argument('--list', action='store', dest='snps_list', required=True)
    parser.add_argument('--log', action='store', dest='log', required=False, default=None)
    args = parser.parse_args()

    __main__(bim_in=args.bim_in,
             bim_out=args.bim_out,
             snps_list=args.snps_list,
             log=args.log)