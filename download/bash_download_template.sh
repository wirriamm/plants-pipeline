echo -e $(date +%Y%m%d-%H%M%S"\t{runid}") >> {init_log_path};
ascp_start=$(date +%s);
timeout 360s ascp -QT -k1 -P33001 -l 300m {ascp_limit_tag} -i {ASPERA_SSH_KEY} era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/{route} '{fastq_out}';
ascp_time=$(echo $(date +%s) - $ascp_start | bc);
sleep 5;
if [ -f {runid}*.aspx ];
  then rm {runid}*;
  echo -e $(date +%Y%m%d-%H%M%S"\t{runid}\tfailed\tfailed\t{layout}") >> {runtime_log_path};
elif [ -f {runid}*.gz ];
  then kallisto_start=$(date +%s);
  kallisto quant -i {idx_path} -t {threads} -o {kal_out} --single -l 200 -s 20 -t 2 {fastq_path};
  kallisto_time=$(echo $(date +%s) - $kallisto_start | bc);
  rm {fastq_path};
  zip -r {runid}.zip {runid}/;
  rm -r {runid};
  echo -e $(date +%Y%m%d-%H%M%S"\t{runid}\t$ascp_time\t$kallisto_time\t{layout}") >> {runtime_log_path};
fi
