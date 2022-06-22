import yaml
import random
import argparse


# need to add some random no. xor/or/and operations
def interface_algorithm(f, interface_name, input_bits, output_bits,interconnect_list):

    f.writelines("\n")
    f.writelines("module " + interface_name + "(input reg [" + str(int(input_bits - 1)) + ":0] inp, " + "output reg [" + str(int(output_bits - 1)) + ":0] outp, input clk, input reset);" + "\n")

    #list1 = ["fsm","xor_module","mux_module"]
    list1 = interconnect_list
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
        l = "intermediate_wire"
        #f.writelines("reg [" + str(int(input_bits -1 )) + ":0]" + L + "_" + str(i) + "; \n" )
        #f.writelines("always@(posedge clk) begin \n")
        #f.writelines(L + "_" + str(i) + " <= inp; \n" )
        #f.writelines("end \n \n")
        #if int(input_bits/output_bits) > 2:
        loop = 1
        new_input_bits = input_bits
        odd_flag = 0

        while loop:
            odd_flag = 0
            if i == 0:
                f.writelines("reg [" + str(int(new_input_bits -1 )) + ":0]" + L + "_" + str(i) + "; \n" )
                f.writelines("always@(posedge clk) begin \n")
                f.writelines(L + "_" + str(i) + " <= inp; \n" )
                f.writelines("end \n \n")
                #continue   # not sure if this is needed here
            else:
                pass

            if new_input_bits%2 == 1:  #if it is odd
                odd_flag = 1
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
                        #f.writelines("always@(posedge clk) begin \n")
                        f.writelines("wire [" + str(int(new_input_bits-2)) + ":0]" + l + "_" + str(i) + "; \n")
                        f.writelines("assign " + l + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "] = " + L + "_" + str(i) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "] ; \n")
                        f.writelines("assign " + l + "_" + str(i) + "[" + str(int(new_input_bits-3)) + ":0] = " + L + "_" + str(int(i)) + "[" + str(int(new_input_bits-3)) + ":0] ; \n")
                        #f.writelines(L + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "]" " <= " + L + "_" + str(i) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "] ; \n" )
                        #f.writelines("end \n \n")
                    else:
                        #f.writelines("always@(posedge clk) begin \n")
                        f.writelines("wire [" + str(int(new_input_bits-2)) + ":0]" + l + "_" + str(i) + "; \n")
                        f.writelines("assign " + l + "_" + str(i) + "[" + str(int(new_input_bits-2)) + "] = " + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-2)) + "] ; \n")
                        f.writelines("assign " + l + "_" + str(i) + "[" + str(int(new_input_bits-3)) + ":0] = " + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-3)) + ":0] ; \n")
                        #f.writelines(L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-2)) + "]" " <= " + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-1)) + "]" + "^" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits-2)) + "] ; \n" )
                        #f.writelines("end \n \n")
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
                    sel = L + "_" + str(int(i-1)) + "[0]"

                    if odd_flag == 0:
                        for k in range(int(new_input_bits/2)):
                            #f.writelines(L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" "<= " + L +"_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "^" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "] ;\n" )
                            func = random.choice(list1)
                            if func == "mux_module":
                                f.writelines(func + " " + func + "_inst" + "_" + str(i) + "_" + str(k) + "(.clk(clk),.reset(reset),.i1(" + L +"_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "),.i2(" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "]" + "),.o(" + L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" + "),.sel(" + sel + ")); \n")
                            else:
                                f.writelines(func + " " + func + "_inst" + "_" + str(i) + "_" + str(k) + "(.clk(clk),.reset(reset),.i1(" + L +"_" + str(int(i-1)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "),.i2(" + L + "_" + str(int(i-1)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "]" + "),.o(" + L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" + ")); \n")
                    else:
                        for k in range(int(new_input_bits/2)):
                            func = random.choice(list1)
                            if func == "mux_module":
                                f.writelines(func + " " + func + "_inst" + "_" + str(i) + "_" + str(k) + "(.clk(clk),.reset(reset),.i1(" + l +"_" + str(int(i)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "),.i2(" + l + "_" + str(int(i)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "]" + "),.o(" + L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" + "),.sel(" + sel + ")); \n")
                            else:
                                f.writelines(func + " " + func + "_inst" + "_" + str(i) + "_" + str(k) + "(.clk(clk),.reset(reset),.i1(" + l +"_" + str(int(i)) + "[" + str(int(new_input_bits - 1 - (2*k)) ) + "]" + "),.i2(" + l + "_" + str(int(i)) + "[" + str(int(new_input_bits - 2 - (2*k)) ) + "]" + "),.o(" + L + "_" + str(i) + "[" + str(int((new_input_bits/2) -1 - k)) + "]" + ")); \n")
                    #f.writelines("end \n \n")
                    new_input_bits = new_input_bits/2
                    i = i + 1
                    continue

                if new_input_bits < output_bits:

                    round_down = int(output_bits/new_input_bits)
                    f.writelines("always@(posedge clk) begin \n")
                    for z in range(round_down):
                        if odd_flag == 0:
                            f.writelines("outp [" + str(int(((z+1)*new_input_bits)-1)) + ":" + str(int(z*new_input_bits)) + "] <= " + L + "_" + str(int(i-1)) + "; \n" )
                        else:
                            f.writelines("outp [" + str(int(((z+1)*new_input_bits)-1)) + ":" + str(int(z*new_input_bits)) + "] <= " + l + "_" + str(int(i)) + "; \n" )
                    if output_bits%new_input_bits != 0:
                        if odd_flag == 0:
                            f.writelines("outp[" + str(int(output_bits - 1)) + ":" + str(int(output_bits - (output_bits%new_input_bits) )) + "] <= " + L + "_" + str(int(i-1)) + "[" + str(int( (output_bits%new_input_bits) - 1 )) + ":0] ; \n")
                        else:
                            f.writelines("outp[" + str(int(output_bits - 1)) + ":" + str(int(output_bits - (output_bits%new_input_bits) )) + "] <= " + l + "_" + str(int(i)) + "[" + str(int( (output_bits%new_input_bits) - 1 )) + ":0] ; \n")

                    f.writelines("end \n")
                    i = i+1
                    loop = 0
                    break

                if new_input_bits == output_bits:

                    f.writelines("always@(posedge clk) begin \n")
                    if odd_flag == 0:
                        f.writelines("outp[" + str(int(output_bits - 1)) +  "] <= " + L + "_" + str(int(i-1)) + " ; \n")
                    else:
                        f.writelines("outp[" + str(int(output_bits - 1)) +  "] <= " + l + "_" + str(int(i)) + " ; \n")
                    f.writelines("end \n")

                    i = i+1
                    loop = 0
                    break

            if new_input_bits == 0:
                loop = 0
                continue;

    f.writelines("endmodule \n \n")
    print("module " + interface_name + " generated \n")

#module_inputs_dict contains the no. of input bits, indexed by type and size
#module_outputs_dict contains the no. of output bits, indexed by type and size
def generate_interface(hardware, instance, module_dict,interconnect_list):
    no_of_instances = len(instance)
    print(instance)
    print(instance[0])
    no_of_input_bits = 0
    interface_input_bits = 0
    interface_output_bits = 0
    with open("interfaces.v", "w") as f:
        f.writelines("\n")
        for i in range(no_of_instances):
            # f.writelines("\n")
            interface_name = "interface_" + str(i)
            print(i)
            h = instance[i]
            print(h)
            type = hardware[instance[i]]["type"]
            size = hardware[instance[i]]["size"]
            precision = hardware[instance[i]]["precision"]
            number = hardware[instance[i]]["number"]

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
                    interface_output_bits = module_dict[type][module[j]]["inputs"]*number
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
                    number_x = hardware[x]["number"]
                    module_x = []
                    for z in module_dict[type_x]:
                        module_x.append(z)
                    module_x_len = len(module_x)


                    for y in range(module_x_len):
                        if (module_dict[type_x][module_x[y]]["size"] == size_x) and (module_dict[type_x][module_x[y]]["precision"] == precision_x):
                            interface_input_bits = interface_input_bits + (module_dict[type_x][module_x[y]]["outputs"]*number_x)
                        else:
                            pass

            interface_algorithm(f,interface_name,interface_input_bits,interface_output_bits,interconnect_list)
    print("all interface modules generated")

def generate_parallel_modules(hardware,instance,module_dict):
    no_of_instances = len(instance)
    module_names = []
    module_numbers = []
    with open("parallel_modules.v", "w") as f:
        for i in range(no_of_instances):
            f.writelines("\n")
            flag = 0
            instance_name = instance[i]
            type = hardware[instance[i]]["type"]
            size = hardware[instance[i]]["size"]
            precision = hardware[instance[i]]["precision"]
            number = hardware[instance[i]]["number"]
           # module_numbers.append(number)
            module = []
            for k in module_dict[type]:
                module.append(k)
            module_len = len(module)



            for j in range(module_len):
                if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                    name = module_dict[type][module[j]]["name"]
                    #num = module_dict[type][module[j]]["numbers"]
                    #module_names.append(name)
                    #module_numbers.append(num)

                    module_names_len = len(module_names)

                    for z in range(module_names_len):
                        if((module_names[z] == name) and (module_numbers[z] == number)):
                            flag = 1
                            print("\n flag is 1 for: \n" + "module " + name + "_" + str(number) + "\n")
                            break
                        else:
                            pass
                    if (flag == 1):
                        break
                    else:
                        pass
                    module_names.append(name)
                    module_numbers.append(number)
                    ins = module_dict[type][module[j]]["inputs"]
                    out = module_dict[type][module[j]]["outputs"]
                    inp = ins*number
                    outp = out*number
                    parallel_name = name + "_" + str(number)
                    f.writelines("module " + parallel_name + "(input clk, input reset, input[" + str(int(inp-1)) + ":0] inp, output reg [" + str(int(outp-1)) + ":0] outp); \n")
                    for y in range(number):
                        f.writelines("\n" + name + " inst_" + str(y) + " (.clk(clk),.reset(reset),.inp(inp[" + str(int((ins*(y+1))-1)) + ":" + str(int((ins*y))) + "]),.outp(outp[" + str(int((out*(y+1))-1)) + ":" + str(int((out*y))) + "])); \n")
                    f.writelines("\n" + "endmodule \n")
                else:
                    pass

            if (flag == 1):
                continue
            else:
                pass

def matching_assertion(x,y):
    assert (x == y), f"Values given in yaml file and module dictionary do not match: {x}"

def assertions_function(hardware, instance, module_dict):
    no_of_instances = len(instance)
    top_inp_flag = 0
    top_outp_flag = 0
    instance_track = []

    for i in range(no_of_instances):
        instance_name = instance[i]
        type = hardware[instance[i]]["type"]
        size = hardware[instance[i]]["size"]
        precision = hardware[instance[i]]["precision"]
        number = hardware[instance[i]]["number"]

        instance_track.append(instance[i])
        instance_track_len = len(instance_track)

    for i in range(no_of_instances):
        instance_name = instance[i]
        type = hardware[instance[i]]["type"]
        types = hardware[instance[i]]["type"]
        size = hardware[instance[i]]["size"]
        precision = hardware[instance[i]]["precision"]
        number = hardware[instance[i]]["number"]
       # print(type)
        assert(number>= 1), f"Number is less than one: {number}"

        module_d = []

        for z in module_dict:
            module_d.append(z)
           # print(z)
        module_len_d = len(module_d)

        type_flag = 0
        size_flag = 0
        precision_flag = 0

        for y in range(module_len_d):
            if module_d[y] == type:
            #    print("succes")
                type_flag =1
               # pass
            else:
                pass
                #matching_assertion(type,module_d[y])

        module = []
        for k in module_dict[type]:
            module.append(k)
        module_len = len(module)

            #module_dict stores the no. of input bits to a particular instance
            #determining input bits to the ith instance, which is output bits of the interface
        for j in range(module_len):
            if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                #pass
                matching_assertion(size,module_dict[type][module[j]]["size"])
                matching_assertion(precision,module_dict[type][module[j]]["precision"])
                size_flag =1
                precision_flag = 1
            else:
                #matching_assertion(size,module_dict[type][module[j]]["size"])
                #matching_assertion(precision,module_dict[type][module[j]]["precision"])
                pass

        if type_flag == 0:
            matching_assertion(type,module_d[y])
        else:
            pass

        if size_flag == 0:
            matching_assertion(size,module_dict[type][module[j]]["size"])
        else:
            pass

        if precision_flag == 0:
            matching_assertion(precision,module_dict[type][module[j]]["precision"])
        else:
            pass

        if hardware[instance[i]]["inputs"][0] == "top":
            top_inp_flag = 1
        else:
            pass

        if hardware[instance[i]]["outputs"][0] == "top":
            top_outp_flag = 1
        else:
            pass

        inst_flag = 0
        if hardware[instance[i]]["inputs"][0] == "top":
            pass # no interface is made for this instances input since input is coming from top
        else:
            #counting the inputs that are tring to go into this instantiation
            for x in hardware[instance[i]]["inputs"]: # x is the name of the input instances to ith instance
                #interface_input_bits = interface_input_bits + module_outputs_dict[x]
                type_x = hardware[x]["type"]
                size_x = hardware[x]["size"]
                precision_x = hardware[x]["precision"]
                number_x = hardware[x]["number"]

                assert(x != instance[i]), f"instance is input to itself :{instance[i]}"

                inst_flag = 0

                for y in range(instance_track_len):
                    if(instance_track[y] == x):
                        inst_flag = 1
                    else:
                        pass
                assert(inst_flag == 1), f"Instance: {x} is not present as inputs to any other instance"

        inst_flag = 0
        if hardware[instance[i]]["outputs"][0] == "top":
            pass # no interface is made for this instances input since input is coming from top
        else:
            #counting the inputs that are tring to go into this instantiation
            for x in hardware[instance[i]]["outputs"]: # x is the name of the input instances to ith instance
                #interface_input_bits = interface_input_bits + module_outputs_dict[x]
                type_x = hardware[x]["type"]
                size_x = hardware[x]["size"]
                precision_x = hardware[x]["precision"]
                number_x = hardware[x]["number"]

                assert(x != instance[i]), f"instance is output to itself :{instance[i]}"

                inst_flag = 0

                for y in range(instance_track_len):
                    if(instance_track[y] == x):
                        inst_flag = 1
                    else:
                        pass
                assert(inst_flag == 1), f"Instance: {x} is not present as outputs to any other instance"



    assert(top_inp_flag == 1), "No instance has top as inputs to it"
    assert(top_outp_flag == 1), "No instance has top as outputs to it"

def generate_top(hardware, instance, module_dict):
    no_of_instances = len(instance)
    top_input_bits = 0
    top_output_bits = 0
    with open("top.v", "w") as f:
        f.writelines("\n")
        for t in range(no_of_instances): #going through all instances

            flag_ti = 0
            flag_to = 0

            if (hardware[instance[t]]["inputs"][0] != "top") and (hardware[instance[t]]["outputs"][0] != "top"):
                continue
            else:
                pass

            #checking if inputs to that instance is top
            if hardware[instance[t]]["inputs"][0] == "top":
                type_ti = hardware[instance[t]]["type"]
                size_ti = hardware[instance[t]]["size"]
                precision_ti = hardware[instance[t]]["precision"]
                number_ti = hardware[instance[t]]["number"]
                flag_ti = 1
            else:
                pass

            #checking if outputs to that instance is top
            if hardware[instance[t]]["outputs"][0] == "top":
                type_to = hardware[instance[t]]["type"]
                size_to = hardware[instance[t]]["size"]
                precision_to = hardware[instance[t]]["precision"]
                number_to = hardware[instance[t]]["number"]
                flag_to = 1
            else:
                pass

            # going through module dictionary and fetching all modules of type_ti
            if flag_ti == 1:
                module_ti = []
                for tmi in module_dict[type_ti]:
                    module_ti.append(tmi)
                module_len_ti = len(module_ti)
            else:
                pass

            # going through module dictionary and fetching all modules of type_to
            if flag_to == 1:
                module_to = []
                for tmo in module_dict[type_to]:
                    module_to.append(tmo)
                module_len_to = len(module_to)
            else:
                pass

            #matching module dict with instance parameters and counting top input and output bits
            if flag_ti == 1:
                for tij in range(module_len_ti):
                    if (module_dict[type_ti][module_ti[tij]]["size"] == size_ti) and (module_dict[type_ti][module_ti[tij]]["precision"] == precision_ti):
                        top_input_bits = top_input_bits + (module_dict[type_ti][module_ti[tij]]["inputs"]*number_ti)
                    else:
                        pass
            else:
                pass

            if flag_to == 1:
                for toj in range(module_len_to):
                    if (module_dict[type_to][module_to[toj]]["size"] == size_to) and (module_dict[type_to][module_to[toj]]["precision"] == precision_to):
                        top_output_bits = top_output_bits + (module_dict[type_to][module_to[toj]]["outputs"]*number_to)
                    else:
                        pass
            else:
                pass

        f.writelines("module top (input clk, input reset,input [" + str(int(top_input_bits - 1)) + ":0] top_inp, output [" + str(int(top_output_bits - 1)) + ":0] top_outp); \n \n")

        for i in range(no_of_instances):
            f.writelines("\n")
            interface_name = "interface_" + str(i)
            instance_name = instance[i]
            instance_input_bits = 0
            instance_output_bits = 0

            type = hardware[instance[i]]["type"]
            size = hardware[instance[i]]["size"]
            precision = hardware[instance[i]]["precision"]
            number = hardware[instance[i]]["number"]

            interface_output_bits = 0
            interface_input_bits = 0

            module = []
            for k in module_dict[type]:
                module.append(k)
            module_len = len(module)

            #module_dict stores the no. of input bits to a particular instance
            #determining input bits to the ith instance, which is output bits of the interface
            # finding inp/outp bits to an instance
            for j in range(module_len):
                if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                    interface_output_bits = module_dict[type][module[j]]["inputs"]*number
                    instance_input_bits = module_dict[type][module[j]]["inputs"]*number
                    instance_output_bits = module_dict[type][module[j]]["outputs"]*number
                    module_name = module_dict[type][module[j]]["name"] + "_" + str(number)
                    f.writelines("\n wire [" + str(int(instance_input_bits-1)) + ":0] inp_" + instance_name + ";\n" )
                    f.writelines("wire [" + str(int(instance_output_bits-1)) + ":0] outp_" + instance_name + ";\n" )
                    f.writelines("\n" + module_name + " " + instance_name + " (.clk(clk),.reset(reset),.inp(inp_" + instance_name + "),.outp(outp_" + instance_name + ")); \n")
                else:
                    #print("Error: Instance " + instance_name + "does not match any module in module_dict")
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
                    number_x = hardware[x]["number"]
                    module_x = []
                    for z in module_dict[type_x]:
                        module_x.append(z)
                    module_x_len = len(module_x)


                    for y in range(module_x_len):
                        if (module_dict[type_x][module_x[y]]["size"] == size_x) and (module_dict[type_x][module_x[y]]["precision"] == precision_x):
                            interface_input_bits = interface_input_bits + (module_dict[type_x][module_x[y]]["outputs"]*number_x)
                        else:
                            pass

            f.writelines("wire [" + str(int(interface_input_bits - 1)) + ":0] inp_" + interface_name + "; \n")
            f.writelines("wire [" + str(int(interface_output_bits - 1)) + ":0] outp_" + interface_name + "; \n")
            f.writelines("\n" + interface_name + " inst_" + interface_name + "(.clk(clk),.reset(reset),.inp(inp_" + interface_name + "),.outp(outp_" + interface_name + ")); \n")

        top_in_bits = 0
        top_out_bits = 0
        for i in range(no_of_instances):
            f.writelines("\n")
            interface_name = "interface_" + str(i)
            L = "assign inp_" + interface_name + " = {"
            instance_name = instance[i]
            instance_input_bits = 0
            instance_output_bits = 0

            type = hardware[instance[i]]["type"]
            size = hardware[instance[i]]["size"]
            precision = hardware[instance[i]]["precision"]
            number = hardware[instance[i]]["number"]

            interface_output_bits = 0
            interface_input_bits = 0


            module = []
            for k in module_dict[type]:
                module.append(k)
            module_len = len(module)

            #module_dict stores the no. of input bits to a particular instance
            #determining input bits to the ith instance, which is output bits of the interface
            # finding inp/outp bits to an instance
            for j in range(module_len):
                if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                    interface_output_bits = module_dict[type][module[j]]["inputs"]*number
                    instance_input_bits = module_dict[type][module[j]]["inputs"]*number
                    instance_output_bits = module_dict[type][module[j]]["outputs"]*number
                    module_name = module_dict[type][module[j]]["name"] + "_" + str(number)
                    if hardware[instance[i]]["inputs"][0] != "top":
                        f.writelines("assign inp_" + instance_name + " = outp_" + interface_name + "; \n")
                    else:
                        top_in_bits = top_in_bits + instance_input_bits

                else:
                    #print("Error: Instance " + instance_name + "does not match any module in module_dict")
                    pass

            if hardware[instance[i]]["outputs"][0] == "top":
                top_out_bits = top_out_bits + instance_output_bits
                f.writelines("assign top_outp[" + str(int(top_out_bits -1)) + ":" + str(int(top_out_bits - instance_output_bits)) + "] = " + "outp_" + instance_name + "; \n")
            else:
                pass

            if hardware[instance[i]]["inputs"][0] == "top":
                f.writelines("assign inp_" + instance_name + " = top_inp[" + str(int(top_in_bits - 1)) + ":" + str(int(top_in_bits - instance_input_bits)) + "]; \n" )
            else:
                #counting the inputs that are tring to go into this instantiation
                len_inps = len(hardware[instance[i]]["inputs"])
                q = 0
                for x in hardware[instance[i]]["inputs"]: # x is the name of the input instances to ith instance
                    #interface_input_bits = interface_input_bits + module_outputs_dict[x]

                    type_x = hardware[x]["type"]
                    size_x = hardware[x]["size"]
                    precision_x = hardware[x]["precision"]
                    number_x = hardware[x]["number"]
                    module_x = []
                    for z in module_dict[type_x]:
                        module_x.append(z)
                    module_x_len = len(module_x)


                    for y in range(module_x_len):
                        if (module_dict[type_x][module_x[y]]["size"] == size_x) and (module_dict[type_x][module_x[y]]["precision"] == precision_x):
                            interface_input_bits = interface_input_bits + (module_dict[type_x][module_x[y]]["outputs"]*number_x)
                        else:
                            pass
                    if q < (len_inps-1):
                        L = L + "outp_" + x + ","
                    else:
                        L = L + "outp_" + x + "}; \n \n"
                    q = q + 1
                f.writelines(L)

        f.writelines("\n endmodule \n")

def print_cat(hardware,instance,module_dict,verilog_file):
    no_of_instances = len(instance)
    file_names = []
    L = "cat top.v interfaces.v parallel_modules.v modules/wrapper_modules/wrapped_modules.v modules/fsm.v modules/xor.v modules/2x1_mux.v  "
    for i in range(no_of_instances):
        instance_name = instance[i]
        type = hardware[instance[i]]["type"]
        size = hardware[instance[i]]["size"]
        precision = hardware[instance[i]]["precision"]
        number = hardware[instance[i]]["number"]

        module = []
        for k in module_dict[type]:
            module.append(k)
        module_len = len(module)

        #module_dict stores the no. of input bits to a particular instance
        #determining input bits to the ith instance, which is output bits of the interface
        # finding inp/outp bits to an instance
        for j in range(module_len):
            if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                file_name = random.choice(module_dict[type][module[j]]["filename"])
                file_names.append(file_name)
            else:
                #print("Error: Instance " + instance_name + "does not match any module in module_dict")
                pass

    unique_list = []
    for i in file_names:
        if i not in unique_list:
            unique_list.append(i)
            L = L + "modules/" + str(i) + " "
        else:
            pass
    L = L + ">> " + str(verilog_file)
    print(L)

def count_resources(hardware,instance,module_dict):
    no_of_instances = len(instance)
    total_io = 0
    total_clb = 0
    total_dsp = 0
    total_bram =  0
    top_output_bits = 0
    top_input_bits = 0
    for i in range(no_of_instances):
        type = hardware[instance[i]]["type"]
        size = hardware[instance[i]]["size"]
        precision = hardware[instance[i]]["precision"]
        number = hardware[instance[i]]["number"]

        clb = 0
        dsp = 0
        bram = 0
        input_bits = 0
        output_bits = 0

        module = []
        for k in module_dict[type]:
            module.append(k)
        module_len = len(module)

        for j in range(module_len):
            if (module_dict[type][module[j]]["size"] == size) and (module_dict[type][module[j]]["precision"] == precision):
                clb = module_dict[type][module[j]]["resource_usage"]["clb"]*number
                dsp = module_dict[type][module[j]]["resource_usage"]["dsp"]*number
                bram = module_dict[type][module[j]]["resource_usage"]["bram"]*number
                input_bits = module_dict[type][module[j]]["inputs"]*number
                output_bits = module_dict[type][module[j]]["outputs"]*number
                total_clb = total_clb + clb
                total_dsp = total_dsp + dsp
                total_bram = total_bram + bram
            else:
                pass

        if hardware[instance[i]]["outputs"][0] == "top":
            top_output_bits = top_output_bits + output_bits
        else:
            pass

        if hardware[instance[i]]["inputs"][0] == "top":
            top_input_bits = top_input_bits + input_bits
        else:
            pass

    total_io = top_input_bits + top_output_bits
    print("\n")
    print("Total Number of Expected Resources Used:\n IO:" + str(total_io) + "\n CLB:" + str(total_clb) + "\n DSP:" + str(total_dsp) + "\n BRAM:" + str(total_bram) + "\n")


parser = argparse.ArgumentParser()
parser.add_argument("-i","--interconnect",action='store',default="fsm,xor_module,mux_module",help="List of hardware in interconnect")
parser.add_argument("-y","--yaml_file",action='store',default="graphs/simple.yml",help="provide yaml file")
parser.add_argument("-v","--verilog_file",action='store',default="all.v",help="provide verilog file to write to")
args = parser.parse_args()
interconnect_list = [str(item) for item in args.interconnect.split(',')]
verilog_file = args.verilog_file
#structure.yml is the yaml file provided by user
with open(args.yaml_file, "r") as ymlfile:
    hardware = yaml.safe_load(ymlfile)

# empty list created that will store instance names
instance = []

# generating list of hardware instance names
# this names list will be used to index into hardware
for instance_name in hardware:
    instance.append(instance_name)

no_of_instances = len(instance)


#top_inputs = 0
#top_outputs = 0

# determining the number of inputs/outputs for the top module. Perhaps bit width might also be required here.
# if constant bitwidth kept then I will multiply bitwidth with the final output.
# actually I should hold out on this since some are 32 bits while some are 16 etc.
#for i in range(no_of_instances):
#    if hardware[instance[i]]["inputs"] == top:
#        top_inputs = top_inputs + (module_inputs_dict[hardware[instance[i]]["type"]][hardware[instance[i]]["size"]])*(module_bitwidth_dict[hardware[instance[i]]["type"]])
    #    top_outputs = top_outputs +

# this dictionary containts the np. of inputs/outputs of a hardware module of a particular size
# size is the index
# maybe have the dictionary contain total no. of inputs/outputs bits
# nested dictionary
module_dict = {
"adder_tree": {
    "module1" : {
        "name": "adder_tree_1_16bit",
        "size":1,
        "precision":16,
        "inputs":32,
        "outputs":32,
        "filename": ["adder_tree_1stage_16bit.v"],
        "resource_usage": {"io":66,"clb":17,"dsp":0,"bram":0},},
    "module2": {
        "name": "adder_tree_2_16bit",
        "size":2,
        "precision":16,
        "inputs":64,
        "outputs":32,
        "filename": ["adder_tree_2stage_16bit.v"],
        "resource_usage": {"io":98,"clb":18,"dsp":0,"bram":0},},
    "module3": {
        "name": "adder_tree_3_16bit",
        "size":3,
        "precision":16,
        "inputs":128,
        "outputs":32,
        "filename": ["adder_tree_3stage_16bit.v"],
        "resource_usage": {"io":162,"clb":21,"dsp":0,"bram":0},},
    "module4": {
        "name": "adder_tree_4_16bit",
        "size":4,
        "precision":16,
        "inputs":256,
        "outputs":32,
        "filename": ["adder_tree_4stage_16bit.v"],
        "resource_usage": {"io":290,"clb":29,"dsp":0,"bram":0},},
    "module5" : {
        "name": "adder_tree_1_8bit",
        "size":1,
        "precision":8,
        "inputs":16,
        "outputs":16,
        "filename": ["adder_tree_1stage_8bit.v"],
        "resource_usage": {"io":34,"clb":8,"dsp":0,"bram":0},},
    "module6": {
        "name": "adder_tree_2_8bit",
        "size":2,
        "precision":8,
        "inputs":32,
        "outputs":16,
        "filename": ["adder_tree_2stage_8bit.v"],
        "resource_usage": {"io":50,"clb":9,"dsp":0,"bram":0},},
    "module7": {
        "name": "adder_tree_3_8bit",
        "size":3,
        "precision":8,
        "inputs":64,
        "outputs":16,
        "filename": ["adder_tree_3stage_8bit.v"],
        "resource_usage": {"io":82,"clb":13,"dsp":0,"bram":0},},
    "module8": {
        "name": "adder_tree_4_8bit",
        "size":4,
        "precision":8,
        "inputs":128,
        "outputs":16,
        "filename": ["adder_tree_4stage_8bit.v"],
        "resource_usage": {"io":146,"clb":20,"dsp":0,"bram":0},},
    "module9" : {
        "name": "adder_tree_1_4bit",
        "size":1,
        "precision":4,
        "inputs":8,
        "outputs":8,
        "filename": ["adder_tree_1stage_4bit.v"],
        "resource_usage": {"io":18,"clb":4,"dsp":0,"bram":0},},
    "module10": {
        "name": "adder_tree_2_4bit",
        "size":2,
        "precision":4,
        "inputs":16,
        "outputs":8,
        "filename": ["adder_tree_2stage_4bit.v"],
        "resource_usage": {"io":26,"clb":5,"dsp":0,"bram":0},},
    "module11": {
        "name": "adder_tree_3_4bit",
        "size":3,
        "precision":4,
        "inputs":32,
        "outputs":8,
        "filename": ["adder_tree_3stage_4bit.v"],
        "resource_usage": {"io":42,"clb":8,"dsp":0,"bram":0},},
    "module12": {
        "name": "adder_tree_4_4bit",
        "size":4,
        "precision":4,
        "inputs":64,
        "outputs":8,
        "filename": ["adder_tree_4stage_4bit.v"],
        "resource_usage": {"io":74,"clb":15,"dsp":0,"bram":0},},
    "module13": {
        "name": "adder_tree_3_fp16bit",
        "size":3,
        "precision": "fp16",
        "inputs":132,
        "outputs":16,
        "filename": ["adder_tree_3stage_fp16bit.v"],
        "resource_usage": {"io":150,"clb":148,"dsp":0,"bram":0},}
    },
"systolic_array": {
    "module1": {
        "name": "systolic_array_4_16bit",
        "size":4,
        "precision":16,
        "inputs":253,
        "outputs":131,
        "filename": ["systolic_4x4.v"],
        "resource_usage": {"io":388,"clb":81,"dsp":16,"bram":0},},
    "module2": {
        "name": "systolic_array_8_16bit",
        "size":8,
        "precision":16,
        "inputs":775,
        "outputs":434,
        "filename": ["systolic_8x8.v"],
        "resource_usage": {"io":1222,"clb":608,"dsp":64,"bram":0},},
    "module3": {
        "name": "systolic_array_4_fp16bit",
        "size":4,
        "precision": "fp16",
        "inputs":435,
        "outputs":224,
        "filename": ["systolic_4x4_fp.v"],
        "resource_usage": {"io":644,"clb":86,"dsp":16,"bram":0},}
    },
"dot_product": {
    "module1": {
        "name": "tensor_block_bf16_module",
        "size":10,
        "precision":"fp16",
        "inputs":265,
        "outputs":272,
        "filename": ["tensor_block_bf16.v"],
        "resource_usage": {"io":539,"clb":495,"dsp":3,"bram":0},},
    "module2": {
        "name": "tensor_block_int8_module",
        "size":10,
        "precision":8,
        "inputs":265,
        "outputs":251,
        "filename": ["tensor_block_int8.v"],
        "resource_usage": {"io":518,"clb":119,"dsp":10,"bram":0},}
    },
"relu": {
    "module1": {
        "name": "activation_32_8bit_module",
        "size":32,
        "precision":8,
        "inputs":261,
        "outputs":258,
        "filename": ["activations_8bit.v"],
        "resource_usage": {"io":519,"clb":127,"dsp":8,"bram":0},},
    "module2": {
        "name": "activation_32_16bit_module",
        "size":32,
        "precision":16,
        "inputs":516,
        "outputs":514,
        "filename": ["activations_16bit.v"],
        "resource_usage": {"io":1031,"clb":211,"dsp":16,"bram":0},}
    },
"tanh": {
    "module1": {
        "name": "activation_32_8bit_module",
        "size":32,
        "precision":8,
        "inputs":261,
        "outputs":258,
        "filename": ["activations_8bit.v"],
        "resource_usage": {"io":519,"clb":127,"dsp":8,"bram":0},},
    "module2": {
        "name": "activation_32_16bit_module",
        "size":32,
        "precision":16,
        "inputs":516,
        "outputs":514,
        "filename": ["activations_16bit.v"],
        "resource_usage": {"io":1031,"clb":211,"dsp":16,"bram":0},},
    "module3": {
        "name": "tanh_16bit",
        "size":16,
        "precision":16,
        "inputs":16,
        "outputs":16,
        "filename": ["tanh.v"],
        "resource_usage": {"io":32,"clb":9,"dsp":0,"bram":0},}
    },
"sigmoid": {
    "module1": {
        "name": "sigmoid_16bit",
        "size":16,
        "precision":16,
        "inputs":16,
        "outputs":16,
        "filename": ["sigmoid.v"],
        "resource_usage": {"io":32,"clb":10,"dsp":0,"bram":0},}
    },
"dpram": {
    "module1": {
        "name": "dpram_1024_40bit_module",
        "size":1024,
        "precision":40,
        "inputs":102,
        "outputs":80,
        "filename": ["dpram_1024_40bit.v"],
        "resource_usage": {"io":185,"clb":0,"dsp":0,"bram":4},},
    "module2": {
        "name": "dpram_1024_60bit_module",
        "size":1024,
        "precision":60,
        "inputs":142,
        "outputs":120,
        "filename": ["dpram_1024_60bit.v"],
        "resource_usage": {"io":100,"clb":100,"dsp":100,"bram":100},},
    "module3": {
        "name": "dpram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":104,
        "outputs":80,
        "filename": ["dpram_2048_40bit.v"],
        "resource_usage": {"io":185,"clb":0,"dsp":0,"bram":4},},
    "module4": {
        "name": "dpram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":144,
        "outputs":120,
        "filename": ["dpram_2048_60bit.v"],
        "resource_usage": {"io":265,"clb":0,"dsp":0,"bram":6},},
    "module5": {
        "name": "dpram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":106,
        "outputs":80,
        "filename": ["dpram_4096_40bit.v"],
        "resource_usage": {"io":187,"clb":6,"dsp":0,"bram":8},},
    "module6": {
        "name": "dpram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":146,
        "outputs":120,
        "filename": ["dpram_4096_60bit.v"],
        "resource_usage": {"io":267,"clb":8,"dsp":0,"bram":12},},
    },
"spram": {
    "module1": {
        "name": "spram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":52,
        "outputs":40,
        "filename": ["spram_2048_40bit.v"],
        "resource_usage": {"io":93,"clb":0,"dsp":0,"bram":4},},
    "module2": {
        "name": "spram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":72,
        "outputs":60,
        "filename": ["spram_2048_60bit.v"],
        "resource_usage": {"io":133,"clb":0,"dsp":0,"bram":6},},
    "module3": {
        "name": "spram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":53,
        "outputs":40,
        "filename": ["spram_4096_40bit.v"],
        "resource_usage": {"io":94,"clb":3,"dsp":0,"bram":8},},
    "module4": {
        "name": "spram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":73,
        "outputs":60,
        "filename": ["spram_4096_60bit.v"],
        "resource_usage": {"io":134,"clb":4,"dsp":0,"bram":12},},
    },
"dbram": {
    "module1": {
        "name": "dbram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":104,
        "outputs":80,
        "filename": ["dbram_2048_40bit.v"],
        "resource_usage": {"io":186,"clb":10,"dsp":0,"bram":8},},
    "module2": {
        "name": "dbram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":144,
        "outputs":120,
        "filename": ["dbram_2048_60bit.v"],
        "resource_usage": {"io":266,"clb":12,"dsp":0,"bram":12},},
    "module3": {
        "name": "dbram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":106,
        "outputs":80,
        "filename": ["dbram_4096_40bit.v"],
        "resource_usage": {"io":188,"clb":7,"dsp":0,"bram":8},},
    "module4": {
        "name": "dbram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":146,
        "outputs":120,
        "filename": ["dbram_4096_60bit.v"],
        "resource_usage": {"io":268,"clb":9,"dsp":0,"bram":12},},
    },
"fifo": {
    "module1": {
        "name": "fifo_256_40bit_module",
        "size":256,
        "precision":40,
        "inputs":43,
        "outputs":42,
        "filename": ["fifo_256_40bit.v"],
        "resource_usage": {"io":87,"clb":4,"dsp":0,"bram":2},},
    "module2": {
        "name": "fifo_256_60bit_module",
        "size":256,
        "precision":60,
        "inputs":63,
        "outputs":62,
        "filename": ["fifo_256_60bit.v"],
        "resource_usage": {"io":127,"clb":4,"dsp":0,"bram":3},},
    "module3": {
        "name": "fifo_512_40bit_module",
        "size":512,
        "precision":40,
        "inputs":43,
        "outputs":42,
        "filename": ["fifo_512_40bit.v"],
        "resource_usage": {"io":87,"clb":5,"dsp":0,"bram":2},},
    "module4": {
        "name": "fifo_512_60bit_module",
        "size":512,
        "precision":60,
        "inputs":63,
        "outputs":62,
        "filename": ["fifo_512_60bit.v"],
        "resource_usage": {"io":127,"clb":5,"dsp":0,"bram":3},},
    },
"dsp_chain": {
    "module1": {
        "name": "dsp_chain_2_int_sop_2_module",
        "size":2,
        "precision":18,
        "inputs":148,
        "outputs":37,
        "filename": ["dsp_chain_2_int_sop_2.v"],
        "resource_usage": {"io":185,"clb":3,"dsp":2,"bram":0},},
    "module2": {
        "name": "dsp_chain_3_int_sop_2_module",
        "size":3,
        "precision":18,
        "inputs":222,
        "outputs":37,
        "filename": ["dsp_chain_3_int_sop_2.v"],
        "resource_usage": {"io":259,"clb":4,"dsp":3,"bram":0},},
    "module3": {
        "name": "dsp_chain_4_int_sop_2_module",
        "size":4,
        "precision":18,
        "inputs":296,
        "outputs":37,
        "filename": ["dsp_chain_4_int_sop_2.v"],
        "resource_usage": {"io":333,"clb":5,"dsp":4,"bram":0},},
    "module4": {
        "name": "dsp_chain_2_fp16_sop2_mult_module",
        "size":2,
        "precision":"fp16",
        "inputs":128,
        "outputs":32,
        "filename": ["dsp_chain_2_fp16_sop2_mult.v"],
        "resource_usage": {"io":160,"clb":3,"dsp":2,"bram":0},},
    "module5": {
        "name": "dsp_chain_3_fp16_sop2_mult_module",
        "size":3,
        "precision":"fp16",
        "inputs":192,
        "outputs":32,
        "filename": ["dsp_chain_3_fp16_sop2_mult.v"],
        "resource_usage": {"io":224,"clb":4,"dsp":3,"bram":0},},
    "module6": {
        "name": "dsp_chain_4_fp16_sop2_mult_module",
        "size":4,
        "precision":"fp16",
        "inputs":256,
        "outputs":32,
        "filename": ["dsp_chain_4_fp16_sop2_mult.v"],
        "resource_usage": {"io":288,"clb":5,"dsp":4,"bram":0},}
    }
}

assertions_function(hardware, instance, module_dict)
generate_interface(hardware, instance, module_dict,interconnect_list)
generate_top(hardware, instance, module_dict)
generate_parallel_modules(hardware,instance,module_dict)
print_cat(hardware,instance,module_dict,verilog_file)
count_resources(hardware,instance,module_dict)

#with open("final.v", "w") as f:
#    f.writelines()

