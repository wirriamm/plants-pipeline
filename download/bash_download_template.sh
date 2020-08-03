echo -e $(date +%Y%m%d-%H%M%S"\t{runid}") >> {init_log_path};
ascp_start=$(date +%s);
{offset}
timeout 360s ascp -QT -k1 -P33001 -l 300m {ascp_limit_tag} -i "{ASPERA_SSH_KEY}" era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/{route} '{fastq_path}';
ascp_time=$(echo $(date +%s) - $ascp_start | bc);
sleep 5;
if [ -f {fastq_path}.aspx ];
  then rm {fastq_path}*;
  echo -e $(date +%Y%m%d-%H%M%S"\t{runid}\tfailed\tfailed\t{layout}") >> {runtime_log_path};
elif [ -f {fastq_path} ];
  then kallisto_start=$(date +%s);
  kallisto quant -i {idx_path} -t {threads} -o {kal_tmp} --single -l 200 -s 20 {fastq_path};
  kallisto_time=$(echo $(date +%s) - $kallisto_start | bc);
  rm {fastq_path};
  python download/extract_runinfo.py -r {runid} -l {runinfo_log} -k {kal_tmp}/run_info.json;
  rm {kal_tmp}/abundance.h5 {kal_tmp}/run_info.json;
  mkdir -p {kal_out};
  cd "{kal_tmp}/..";
  zip -r {kal_out}{runid}.zip {runid};
  cd "{parent_module}";
  rm -r {kal_tmp};
  echo -e $(date +%Y%m%d-%H%M%S"\t{runid}\t$ascp_time\t$kallisto_time\t{layout}") >> {runtime_log_path};
else
  echo -e $(date +%Y%m%d-%H%M%S"\t{runid}\tfailed\tfailed\t{layout}") >> {runtime_log_path};
fi
