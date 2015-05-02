
 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"


      waveform add -signals /BillPC_tb/status
      waveform add -signals /BillPC_tb/BillPC_synth_inst/bmg_port/CLKA
      waveform add -signals /BillPC_tb/BillPC_synth_inst/bmg_port/ADDRA
      waveform add -signals /BillPC_tb/BillPC_synth_inst/bmg_port/DOUTA
console submit -using simulator -wait no "run"
