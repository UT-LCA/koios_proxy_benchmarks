import yaml
import random


# need to add some random no. xor/or/and operations
def interface_algorithm(f, interface_name, input_bits, output_bits):

    f.writelines("\n")
    f.writelines("module " + interface_name + "(input reg [" + str(int(input_bits - 1)) + ":0] inp, " + "output reg [" + str(int(output_bits - 1)) + ":0] outp);" + "\n")

    list1 = ["fsm","xor_module"]
    func = random.choice(list1)

    if input_bits == output_bits:
        f.writelines("always@(posedge clk) begin \n")
        f.writelines("outp <= inp" + " ; \n") # remove FFFF and make random integer
        f.writelines("end \n")
        f.writelines("endmodule \n")
        print("module " + interface_name + " generated \n")
        return

    if input_bits < output_bits:
        round_down = int(output_bits/input_bits)
        f.writelines("always@(posedge clk) begin \n")

        for i in range(round_down):
            f.writelines("outp[" + str(int(((i+1)*input_bits)-1)) + ":" + str(int(i*input_bits)) + "] <= inp ; \n" )
        if output_bits%input_bits != 0:
            f.writelines("outp[" + str(int(output_bits - 1)) + ":" + str(int(output_bits - (output_bits%input_bits) )) + "] <= inp[" + str(int( (output_bits%input_bits) - 1 )) + ":0] ; \n")
        f.writelines("end \n")
        f.writelines("endmodule \n")
        print("module " + interface_name + " generated \n")
        return

    if input_bits > output_bits:
        #iter = int(input_bits/output_bits)
        L = "intermediate_reg"
        i = 0
        #f.writelines("reg [" + str(int(input_bits -1 )) + ":0]" + L + "_" + str(i) + "; \n" )
        #f.writelines("always@(posedge clk) begin \n")
        #f.writelines(L + "_" + str(i) + " <= inp; \n" )
        #f.writelines("end \n \n")
        #if int(input_bits/output_bits) > 2:
        loop = 1
        new_input_bits = input_bits

        while loop:

            if i == 0:
                f.writelines("reg [" + str(int(new_input_bits -1 )) + ":0]" + L + "_" + str(i) + "; \n" )
                f.writelines("always@(posedge clk) begin \n")
                f.writelines(L + "_" + str(i) + " <= inp; \n" )
                f.writelines("end \n \n")
                #continue   # not sure if this is needed here
            else:
                pass

            if new_input_bits%2 == 1:  #if it is odd
                if output_bits%2 == 1:
                    if i == 0:
                        f.writelines("always@(posedge clk) begin \n")
                        f.writelines("outp[" + str(int(output_bits - 1)) + "] <= " + L + "_" + str(i) + "[" + str(int(new_input_bits - 1)) + "]; \n" )
                        f.writelines("end \n \n")
                    else:
                        f.writelines("always@(posedge clk) begin \n")
                        f.writelines("outp[" + str(int(output_bits - 1)) + "] <= " + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1)) + "]; \n" )
                        f.writelines("end \n \n")
                    output_bits = output_bits -1
                    new_input_bits = new_input_bits -1
                    #now both are even
                else: #if output bits are not odd, we need to make input_bits as even
                    if i ==0:
                        f.writelines("always@(posedge clk) begin \n")
                        f.writelines(L + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "]" " <= " + L + "_" + str(i) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "] ; \n" )
                        f.writelines("end \n \n")
                    else:
                        f.writelines("always@(posedge clk) begin \n")
                        f.writelines(L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-2)) + "]" " <= " + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-2)) + "] ; \n" )
                        f.writelines("end \n \n")
                    new_input_bits = new_input_bits -1 #we have reduced the intermediate_reg bitwidth by 1 (made it even)
            else:
                pass
            if i == 0:
                i = i + 1
                continue
            else:
                #since new_input_bits is even we can divide it by two.
                if new_input_bits > output_bits: #if input bits greater than output bits

                    f.writelines("reg [" + str(int((new_input_bits/2) -1 )) + ":0]" + L + "_" + str(i) + "; \n \n" )
                    #f.writelines("always@(posedge clk) begin \n")


                    for k in range(int(new_input_bits/2)):
                        #f.writelines(L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" "<= " + L +"_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "^" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "] ;\n" )
                        func = random.choice(list1)
                        f.writelines(func + " " + func + "_inst" + "_" + str(i) + "_" + str(k) + "(.i1(" + L +"_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "),.i2(" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "]" + "),.o(" + L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" + "); \n")

                    #f.writelines("end \n \n")
                    new_input_bits = new_input_bits/2
                    i = i + 1
                    continue

                if new_input_bits < output_bits:

                    round_down = int(output_bits/new_input_bits)
                    f.writelines("always@(posedge clk) begin \n")
                    for z in range(round_down):
                        f.writelines("outp [" + str(int(((z+1)*new_input_bits)-1)) + ":" + str(int(z*new_input_bits)) + "] <= " + L + "_" + str(int(i-1)) + "; \n" )
                    if output_bits%new_input_bits != 0:
                        f.writelines("outp[" + str(int(output_bits - 1)) + ":" + str(int(output_bits - (output_bits%new_input_bits) )) + "] <= " + L + "_" + str(int(i-1)) + "[" + str(int( (output_bits%new_input_bits) - 1 )) + ":0] ; \n")
                    f.writelines("end \n")
                    i = i+1
                    loop = 0
                    break

                if new_input_bits == output_bits:

                    f.writelines("always@(posedge clk) begin \n")
                    f.writelines("outp[" + str(int(output_bits - 1)) +  "] <= " + L + "_" + str(int(i-1)) + " ; \n")
                    f.writelines("end \n")
                    i = i+1
                    loop = 0
                    break

            if new_input_bits == 0:
                loop = 0
                continue;

    f.writelines("endmodule \n \n")
    print("module " + interface_name + " generated \n")

def generate_interface(fname, hardware, instance, module_dict):
    no_of_instances = len(instance)
    no_of_input_bits = 0
    interface_input_bits = 0
    interface_output_bits = 0
    with open("interfaces.v", "w") as f:
        f.writelines("\n")
        for i in range(no_of_instances):
            # f.writelines("\n")
            interface_name = "interface_" + str(i)

            type = hardware[instance[i]]["type"]
            size = hardware[instance[i]]["size"]
            precision = hardware[instance[i]]["precision"]

            interface_output_bits = 0
            interface_input_bits = 0

            module = []
            for k in module_dict[type]:
                module.append(k)
            module_len = len(module)

            #module_dict stores the no. of input bits to a particular instance
            #determining input bits to the ith instance, which is output bits of the interface
            for j in range(module_len):
                if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                    interface_output_bits = module_dict[type][module[j]]["inputs"]
                else:
                    pass

            if hardware[instance[i]]["inputs"][0] == "top":
                continue # no interface is made for this instances input since input is coming from top
            else:
                #counting the inputs that are tring to go into this instantiation
                for x in hardware[instance[i]]["inputs"]: # x is the name of the input instances to ith instance
                    #interface_input_bits = interface_input_bits + module_outputs_dict[x]
                    type_x = hardware[x]["type"]
                    size_x = hardware[x]["size"]
                    precision_x = hardware[x]["precision"]
                    module_x = []
                    for z in module_dict[type_x]:
                        module_x.append(z)
                    module_x_len = len(module_x)


                    for y in range(module_x_len):
                        if (module_dict[type_x][module_x[y]]["size"] == size_x) and (module_dict[type_x][module_x[y]]["precision"] == precision_x):
                            interface_input_bits = interface_input_bits + module_dict[type_x][module_x[y]]["inputs"]
                        else:
                            pass

            interface_algorithm(f,interface_name,interface_input_bits,interface_output_bits)
    print("all interface modules generated")

def generate_top(hardware, instance, module_dict):
    no_of_instances = len(instance)
    top_input_bits = 0
    top_output_bits = 0
    with open("interfaces.v", "w") as f:
        f.writelines("\n")
        for t in range(no_of_instances):

            flag_ti = 0
            flag_to = 0

            if (hardware[instance[t]]["inputs"][0] != "top") and (hardware[instance[t]]["outputs"][0] != "top"):
                continue
            else:
                pass

            if hardware[instance[t]]["inputs"][0] == "top":
                type_ti = hardware[instance[t]]["type"]
                size_ti = hardware[instance[t]]["size"]
                precision_ti = hardware[instance[t]]["precision"]
                flag_ti = 1
            else:
                pass

            if hardware[instance[t]]["outputs"][0] == "top":
                type_to = hardware[instance[t]]["type"]
                size_to = hardware[instance[t]]["size"]
                precision_to = hardware[instance[t]]["precision"]
                flag_to = 1
            else:
                pass

            module_ti = []
            for tmi in module_dict[type_ti]:
                module.append(tmi)
            module_len_ti = len(module_ti)

            module_to = []
            for tmo in module_dict[type_to]:
                module.append(tmo)
            module_len_to = len(module_to)

            for tij in range(module_len_ti):
                if (module_dict[type_ti][module[tij]]["size"] == size_ti) and (module_dict[type_ti][module[tij]]["precision"] == precision_ti) and (flag_ti == 1):
                    top_input_bits = top_input_bits + module_dict[type_ti][module[tij]]["inputs"]
                else:
                    pass



        f.writelines("module top (input clk, input reset,input [" + str(int(top_input_bits - 1)) + ":0] inp, output reg [" + str(int(top_output_bits - 1)) + ":0] outp); \n"  )


#structure.yml is the yaml file provided by user
with open("structure.yml", "r") as ymlfile:
    hardware = yaml.safe_load(ymlfile)

# empty list created that will store instance names
instance = []

# generating list of hardware instance names
# this names list will be used to index into hardware
for instance_name in hardware:
    instance.append(instance_name)

no_of_instances = len(instance)

top_inputs = 0
top_outputs = 0

# determining the number of inputs/outputs for the top module. Perhaps bit width might also be required here.
# if constant bitwidth kept then I will multiply bitwidth with the final output.
# actually I should hold out on this since some are 32 bits while some are 16 etc.
for i in range(no_of_instances):
    if hardware[instance[i]]["inputs"] == top:
        top_inputs = top_inputs + (module_inputs_dict[hardware[instance[i]]["type"]][hardware[instance[i]]["size"]])*(module_bitwidth_dict[hardware[instance[i]]["type"]])
        top_outputs = top_outputs +

# this dictionary containts the np. of inputs/outputs of a hardware module of a particular size
# size is the index
# maybe have the dictionary contain total no. of inputs/outputs bits
# nested dictionary
module_dict = {
"adder_tree": {
    "module1" : {
        "name": "adder_tree_1stage_16bit",
        "size":1,
        "precision":16,
        "inputs":32,
        "outputs":32,},
    "module2": {
        "name": "adder_tree_2stage_16bit",
        "size":2,
        "precision":16,
        "inputs":64,
        "outputs":32,},
    "module3": {
        "name": "adder_tree_3stage_16bit",
        "size":3,
        "precision":16,
        "inputs":128,
        "outputs":32,},
    "module4": {
        "name": "adder_tree_4stage_16bit",
        "size":4,
        "precision":16,
        "inputs":256,
        "outputs":32,}
    },
"systolic_array": {
    "module1": {
        "name": "systolic_array_4_16bit",
        "size":4,
        "precision":16,
        "inputs":80,
        "outputs":64 },
    "module2": {
        "name": "systolic_array_8_16bit",
        "size":8,
        "precision":16,
        "inputs":160,
        "outputs":100 }
    }
}


