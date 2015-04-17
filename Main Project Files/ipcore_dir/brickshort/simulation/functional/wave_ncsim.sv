

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /brickshort_tb/status
      waveform add -signals /brickshort_tb/brickshort_synth_inst/bmg_port/CLKA
      waveform add -signals /brickshort_tb/brickshort_synth_inst/bmg_port/ADDRA
      waveform add -signals /brickshort_tb/brickshort_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
