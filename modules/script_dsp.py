with open("dsp_chain_4_fp16_sop2_mult_8.v", "w") as f:
  f.writelines("\n")
  chain = 4
  name = "dsp_chain_" + str(chain) + "_fp16_sop2_mult_module"
  ins = 256
  out = 32
  number = 8
  inp = ins*number
  outp = out*number
  f.writelines("module dsp_chain_" + str(chain) + "_" + name + "_" + str(number) + " (input clk, input reset, input[" + str(int(inp-1)) + ":0] inp, output [" + str(int(outp-1)) + ":0] outp); \n")
  for i in range(number):
    f.writelines("\n dsp_chain_" + str(chain) + "_" + name + " inst" + str(i) + " (.clk(clk),.reset(reset),.inp(inp[" + str(int((ins*(i+1))-1)) + ":" + str(int((ins*i))) + "]),.outp(outp[" + str(int((out*(i+1))-1)) + ":" + str(int((out*i))) + "])); \n")

  f.writelines("\n endmodule \n")
