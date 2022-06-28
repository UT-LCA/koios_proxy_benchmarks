import random
import argparse
import json

#def resource_check(inputs_target,outputs):

def cross_thershold(threshold,val_target,val):
    if(val>(val_target*(1+(threshold/100) ) ) ):
        return 1
    else:
        return 0

def select_hardware(module_dict,resources_dict,hardware_dict,seed,threshold):
    random.seed(seed)
    return_val = 0
    global_i = 0

    inputs_target = resources_dict["inputs"]
    outputs_target = resources_dict["outputs"]
    clb_target = resources_dict["clb"]
    dsp_target = resources_dict["dsp"]
    bram_target = resources_dict["bram"]

    total_inputs = 0
    total_outputs = 0
    total_clb = 0
    total_dsp = 0
    total_bram = 0

    temp_total_inputs = total_inputs
    temp_total_outputs = total_outputs
    temp_total_clb = total_clb
    temp_total_dsp = total_dsp
    temp_total_bram = total_bram

    temp_inputs = 0
    temp_outputs = 0
    temp_clb = 0
    temp_dsp = 0
    temp_bram = 0

    input_threshold = 0
    output_threshold = 0
    clb_threshold = 0
    dsp_threshold = 0
    bram_threshold = 0

    instance_top_inplist = []
    type_top_inplist = []
    size_top_inplist = []
    precision_top_inplist = []
    instance_top_outplist = []
    type_top_outplist = []
    size_top_outplist = []
    precision_top_outplist = []
    instance_list = []
    type_list = []
    size_list = []
    precision_list = []

    temp_instance_type = "dpram"
    temp_instance_module = "module1"

    #generating name list of hardware used
    hardware_list = []
    for i in hardware_dict:
        hardware_list.append(i)
    hardware_list_len = len(hardware_list)

    hardware_weight_list = []
    for i in range(hardware_list_len):
        hardware_weight_list.append(hardware_dict[hardware_list[i]])

    #select hardware that takes input from top
    while(1):
        if(input_threshold==100):
            print("Input instances determined")
            break
        else:
            pass

        temp_instance_type = random.choices(hardware_list,weights=hardware_weight_list,k=1)
        module = []
        for k in module_dict[temp_instance_type[0]]:
            module.append(k)
        module_len = len(module)

        temp_instance_module = random.choice(module)
        temp_inputs = module_dict[temp_instance_type[0]][temp_instance_module]["inputs"]
        temp_clb = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["clb"]
        temp_dsp = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["dsp"]
        temp_bram = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["bram"]
        temp_total_inputs = temp_total_inputs + temp_inputs
        temp_total_clb = temp_total_clb + temp_clb
        temp_total_dsp = temp_total_dsp + temp_dsp
        temp_total_bram = temp_total_bram + temp_bram
        size = module_dict[temp_instance_type[0]][temp_instance_module]["size"]
        precision = module_dict[temp_instance_type[0]][temp_instance_module]["precision"]

        if(cross_thershold(threshold,inputs_target,temp_total_inputs)==0):
            instance_top_inplist.append(temp_instance_type[0] + str(global_i))
            type_top_inplist.append(temp_instance_type[0])
            size_top_inplist.append(size)
            precision_top_inplist.append(precision)
            global_i = global_i + 1
        else:
            #print("Input threshold passed")
            temp_total_inputs = temp_total_inputs - temp_inputs
            temp_total_clb = temp_total_clb - temp_clb
            temp_total_dsp = temp_total_dsp - temp_dsp
            temp_total_bram = temp_total_bram - temp_bram
            input_threshold = input_threshold + 1
            continue;

    #select hardware that outputs to top
    while(1):
        if(output_threshold==100):
            print("output instances determined")
            break
        else:
            pass

        temp_instance_type = random.choices(hardware_list,weights=hardware_weight_list,k=1)
        module = []
        for k in module_dict[temp_instance_type[0]]:
            module.append(k)
        module_len = len(module)

        temp_instance_module = random.choice(module)
        temp_outputs = module_dict[temp_instance_type[0]][temp_instance_module]["outputs"]
        temp_clb = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["clb"]
        temp_dsp = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["dsp"]
        temp_bram = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["bram"]
        temp_total_outputs = temp_total_outputs + temp_outputs
        temp_total_clb = temp_total_clb + temp_clb
        temp_total_dsp = temp_total_dsp + temp_dsp
        temp_total_bram = temp_total_bram + temp_bram
        size = module_dict[temp_instance_type[0]][temp_instance_module]["size"]
        precision = module_dict[temp_instance_type[0]][temp_instance_module]["precision"]

        if(cross_thershold(threshold,outputs_target,temp_total_outputs)==0):
            instance_top_outplist.append(temp_instance_type[0] + str(global_i))
            type_top_outplist.append(temp_instance_type[0])
            size_top_outplist.append(size)
            precision_top_outplist.append(precision)
            global_i = global_i + 1
        else:
            #print("Input threshold passed")
            temp_total_outputs = temp_total_outputs - temp_outputs
            temp_total_clb = temp_total_clb - temp_clb
            temp_total_dsp = temp_total_dsp - temp_dsp
            temp_total_bram = temp_total_bram - temp_bram
            output_threshold = output_threshold + 1
            continue

    while(1):
        if(clb_threshold == 1000):
            print("\n clb threshold iteration limit passed \n")
            break
        else:
            pass
        if(dsp_threshold == 1000):
            print("\n dsp threshold iteration limit passed \n")
            break
        else:
            pass
        if(bram_threshold == 1000):
            print("\n bram threshold iteration limit passed \n")
            break
        else:
            pass

        temp_instance_type = random.choices(hardware_list,weights=hardware_weight_list,k=1)
        module = []
        for k in module_dict[temp_instance_type[0]]:
            module.append(k)
        module_len = len(module)

        temp_instance_module = random.choice(module)
        temp_clb = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["clb"]
        temp_dsp = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["dsp"]
        temp_bram = module_dict[temp_instance_type[0]][temp_instance_module]["resource_usage"]["bram"]
        temp_total_clb = temp_total_clb + temp_clb
        temp_total_dsp = temp_total_dsp + temp_dsp
        temp_total_bram = temp_total_bram + temp_bram
        size = module_dict[temp_instance_type[0]][temp_instance_module]["size"]
        precision = module_dict[temp_instance_type[0]][temp_instance_module]["precision"]

        if((cross_thershold(threshold,clb_target,temp_total_clb)==0) and (cross_thershold(threshold,dsp_target,temp_total_dsp)==0) and (cross_thershold(threshold,bram_target,temp_total_bram)==0)):
            instance_list.append(temp_instance_type[0] + str(global_i))
            type_list.append(temp_instance_type[0])
            size_list.append(size)
            precision_list.append(precision)
            global_i = global_i + 1
        elif (cross_thershold(threshold,clb_target,temp_total_clb)==1):
            temp_total_clb = temp_total_clb - temp_clb
            temp_total_dsp = temp_total_dsp - temp_dsp
            temp_total_bram = temp_total_bram - temp_bram
            clb_threshold = clb_threshold + 1
        elif (cross_thershold(threshold,dsp_target,temp_total_dsp)==1):
            temp_total_clb = temp_total_clb - temp_clb
            temp_total_dsp = temp_total_dsp - temp_dsp
            temp_total_bram = temp_total_bram - temp_bram
            dsp_threshold = dsp_threshold + 1
        elif (cross_thershold(threshold,bram_target,temp_total_bram)==1):
            temp_total_clb = temp_total_clb - temp_clb
            temp_total_dsp = temp_total_dsp - temp_dsp
            temp_total_bram = temp_total_bram - temp_bram
            bram_threshold = bram_threshold + 1
        else:
            print("error in threshold")

    total_inputs = temp_total_inputs
    total_outputs = temp_total_outputs
    total_clb = temp_total_clb
    total_dsp = temp_total_dsp
    total_bram = temp_total_bram
    print("\n total inputs: " + str(total_inputs) + "\n")
    print("\n total outputs: " +str(total_outputs) + "\n")
    print("\n total clb: " + str(total_clb) + "\n")
    print("\n total dsp: " + str(total_dsp) + "\n")
    print("\n total bram: " + str(total_bram) + "\n")



parser = argparse.ArgumentParser()
parser.add_argument("-r","--resources",action='store',type=json.loads,default='{"inputs":500,"outputs":500,"clb":5000,"dsp":500,"bram":500}',help="Key:value of FPGA resources to be used")
parser.add_argument("-ha","--hardware",action='store',type=json.loads,default='{"dpram":30,"systolic_array":40,"adder_tree":30}',help="Key:value of type of hardware to be used")
parser.add_argument("-p","--parallelization",action='store',default=5,help="Parallel tracks in the hardware")
parser.add_argument("-l","--loops",action='store',default=5,help="Number of loops in the hardware")
parser.add_argument("-c","--connectivity",action='store',type=json.loads,default='{"low":1,"high":5}',help="Minimum and maximum number of connections from an instance")
parser.add_argument("-s","--seed",action='store',default=5,help="Seed value")
parser.add_argument("-t","--threshold",action='store',default=10,help="threshold percentage for resources")
args = parser.parse_args()
resources_dict = args.resources
hardware_dict = args.hardware
parallel = args.parallelization
loops = args.loops
connectivity_dict = args.connectivity
seed = args.seed
threshold = args.threshold


module_dict = {
"adder_tree": {
    "module1" : {
        "name": "adder_tree_1_16bit",
        "size":1,
        "precision":16,
        "inputs":32,
        "outputs":32,
        "filename": ["adder_tree_1stage_16bit.v"],
        "resource_usage": {"io":66,"clb":17,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module2": {
        "name": "adder_tree_2_16bit",
        "size":2,
        "precision":16,
        "inputs":64,
        "outputs":32,
        "filename": ["adder_tree_2stage_16bit.v"],
        "resource_usage": {"io":98,"clb":18,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module3": {
        "name": "adder_tree_3_16bit",
        "size":3,
        "precision":16,
        "inputs":128,
        "outputs":32,
        "filename": ["adder_tree_3stage_16bit.v"],
        "resource_usage": {"io":162,"clb":21,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module4": {
        "name": "adder_tree_4_16bit",
        "size":4,
        "precision":16,
        "inputs":256,
        "outputs":32,
        "filename": ["adder_tree_4stage_16bit.v"],
        "resource_usage": {"io":290,"clb":29,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module5" : {
        "name": "adder_tree_1_8bit",
        "size":1,
        "precision":8,
        "inputs":16,
        "outputs":16,
        "filename": ["adder_tree_1stage_8bit.v"],
        "resource_usage": {"io":34,"clb":8,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module6": {
        "name": "adder_tree_2_8bit",
        "size":2,
        "precision":8,
        "inputs":32,
        "outputs":16,
        "filename": ["adder_tree_2stage_8bit.v"],
        "resource_usage": {"io":50,"clb":9,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module7": {
        "name": "adder_tree_3_8bit",
        "size":3,
        "precision":8,
        "inputs":64,
        "outputs":16,
        "filename": ["adder_tree_3stage_8bit.v"],
        "resource_usage": {"io":82,"clb":13,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module8": {
        "name": "adder_tree_4_8bit",
        "size":4,
        "precision":8,
        "inputs":128,
        "outputs":16,
        "filename": ["adder_tree_4stage_8bit.v"],
        "resource_usage": {"io":146,"clb":20,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module9" : {
        "name": "adder_tree_1_4bit",
        "size":1,
        "precision":4,
        "inputs":8,
        "outputs":8,
        "filename": ["adder_tree_1stage_4bit.v"],
        "resource_usage": {"io":18,"clb":4,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module10": {
        "name": "adder_tree_2_4bit",
        "size":2,
        "precision":4,
        "inputs":16,
        "outputs":8,
        "filename": ["adder_tree_2stage_4bit.v"],
        "resource_usage": {"io":26,"clb":5,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module11": {
        "name": "adder_tree_3_4bit",
        "size":3,
        "precision":4,
        "inputs":32,
        "outputs":8,
        "filename": ["adder_tree_3stage_4bit.v"],
        "resource_usage": {"io":42,"clb":8,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module12": {
        "name": "adder_tree_4_4bit",
        "size":4,
        "precision":4,
        "inputs":64,
        "outputs":8,
        "filename": ["adder_tree_4stage_4bit.v"],
        "resource_usage": {"io":74,"clb":15,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},},
    "module13": {
        "name": "adder_tree_3_fp16bit",
        "size":3,
        "precision": "fp16",
        "inputs":132,
        "outputs":16,
        "filename": ["adder_tree_3stage_fp16bit.v"],
        "resource_usage": {"io":150,"clb":148,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},}
    },
"systolic_array": {
    "module1": {
        "name": "systolic_array_4_16bit",
        "size":4,
        "precision":16,
        "inputs":253,
        "outputs":131,
        "filename": ["systolic_4x4.v"],
        "resource_usage": {"io":388,"clb":81,"dsp":16,"bram":0,"mult_9x9":16,"other_dsp":0},},
    "module2": {
        "name": "systolic_array_8_16bit",
        "size":8,
        "precision":16,
        "inputs":775,
        "outputs":434,
        "filename": ["systolic_8x8.v"],
        "resource_usage": {"io":1222,"clb":608,"dsp":64,"bram":0,"mult_9x9":0,"other_dsp":64},},
    "module3": {
        "name": "systolic_array_4_fp16bit",
        "size":4,
        "precision": "fp16",
        "inputs":435,
        "outputs":224,
        "filename": ["systolic_4x4_fp.v"],
        "resource_usage": {"io":644,"clb":86,"dsp":16,"bram":0,"mult_9x9":0,"other_dsp":16},}
    },
"dot_product": {
    "module1": {
        "name": "tensor_block_bf16_module",
        "size":10,
        "precision":"fp16",
        "inputs":265,
        "outputs":272,
        "filename": ["tensor_block_bf16.v"],
        "resource_usage": {"io":539,"clb":495,"dsp":3,"bram":0,"mult_9x9":15,"other_dsp":0},},
    "module2": {
        "name": "tensor_block_int8_module",
        "size":10,
        "precision":8,
        "inputs":265,
        "outputs":251,
        "filename": ["tensor_block_int8.v"],
        "resource_usage": {"io":518,"clb":119,"dsp":10,"bram":0,"mult_9x9":30,"other_dsp":0},}
    },
"relu": {
    "module1": {
        "name": "activation_32_8bit_module",
        "size":32,
        "precision":8,
        "inputs":261,
        "outputs":258,
        "filename": ["activations_8bit.v"],
        "resource_usage": {"io":519,"clb":127,"dsp":8,"bram":0,"mult_9x9":32,"other_dsp":0},},
    "module2": {
        "name": "activation_32_16bit_module",
        "size":32,
        "precision":16,
        "inputs":516,
        "outputs":514,
        "filename": ["activations_16bit.v"],
        "resource_usage": {"io":1031,"clb":211,"dsp":16,"bram":0,"mult_9x9":32,"other_dsp":32},}
    },
"tanh": {
    "module1": {
        "name": "activation_32_8bit_module",
        "size":32,
        "precision":8,
        "inputs":261,
        "outputs":258,
        "filename": ["activations_8bit.v"],
        "resource_usage": {"io":519,"clb":127,"dsp":8,"bram":0,"mult_9x9":32,"other_dsp":0},},
    "module2": {
        "name": "activation_32_16bit_module",
        "size":32,
        "precision":16,
        "inputs":516,
        "outputs":514,
        "filename": ["activations_16bit.v"],
        "resource_usage": {"io":1031,"clb":211,"dsp":16,"bram":0,"mult_9x9":32,"other_dsp":32},},
    "module3": {
        "name": "tanh_16bit",
        "size":16,
        "precision":16,
        "inputs":16,
        "outputs":16,
        "filename": ["tanh.v"],
        "resource_usage": {"io":32,"clb":9,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},}
    },
"sigmoid": {
    "module1": {
        "name": "sigmoid_16bit",
        "size":16,
        "precision":16,
        "inputs":16,
        "outputs":16,
        "filename": ["sigmoid.v"],
        "resource_usage": {"io":32,"clb":10,"dsp":0,"bram":0,"mult_9x9":0,"other_dsp":0},}
    },
"dpram": {
    "module1": {
        "name": "dpram_1024_40bit_module",
        "size":1024,
        "precision":40,
        "inputs":102,
        "outputs":80,
        "filename": ["dpram_1024_40bit.v"],
        "resource_usage": {"io":185,"clb":0,"dsp":0,"bram":4,"mult_9x9":0,"other_dsp":0},},
    "module2": {
        "name": "dpram_1024_60bit_module",
        "size":1024,
        "precision":60,
        "inputs":142,
        "outputs":120,
        "filename": ["dpram_1024_60bit.v"],
        "resource_usage": {"io":100,"clb":100,"dsp":100,"bram":100,"mult_9x9":0,"other_dsp":0},},
    "module3": {
        "name": "dpram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":104,
        "outputs":80,
        "filename": ["dpram_2048_40bit.v"],
        "resource_usage": {"io":185,"clb":0,"dsp":0,"bram":4,"mult_9x9":0,"other_dsp":0},},
    "module4": {
        "name": "dpram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":144,
        "outputs":120,
        "filename": ["dpram_2048_60bit.v"],
        "resource_usage": {"io":265,"clb":0,"dsp":0,"bram":6,"mult_9x9":0,"other_dsp":0},},
    "module5": {
        "name": "dpram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":106,
        "outputs":80,
        "filename": ["dpram_4096_40bit.v"],
        "resource_usage": {"io":187,"clb":6,"dsp":0,"bram":8,"mult_9x9":0,"other_dsp":0},},
    "module6": {
        "name": "dpram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":146,
        "outputs":120,
        "filename": ["dpram_4096_60bit.v"],
        "resource_usage": {"io":267,"clb":8,"dsp":0,"bram":12,"mult_9x9":0,"other_dsp":0},},
    },
"spram": {
    "module1": {
        "name": "spram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":52,
        "outputs":40,
        "filename": ["spram_2048_40bit.v"],
        "resource_usage": {"io":93,"clb":0,"dsp":0,"bram":4,"mult_9x9":0,"other_dsp":0},},
    "module2": {
        "name": "spram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":72,
        "outputs":60,
        "filename": ["spram_2048_60bit.v"],
        "resource_usage": {"io":133,"clb":0,"dsp":0,"bram":6,"mult_9x9":0,"other_dsp":0},},
    "module3": {
        "name": "spram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":53,
        "outputs":40,
        "filename": ["spram_4096_40bit.v"],
        "resource_usage": {"io":94,"clb":3,"dsp":0,"bram":8,"mult_9x9":0,"other_dsp":0},},
    "module4": {
        "name": "spram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":73,
        "outputs":60,
        "filename": ["spram_4096_60bit.v"],
        "resource_usage": {"io":134,"clb":4,"dsp":0,"bram":12,"mult_9x9":0,"other_dsp":0},},
    },
"dbram": {
    "module1": {
        "name": "dbram_2048_40bit_module",
        "size":2048,
        "precision":40,
        "inputs":104,
        "outputs":80,
        "filename": ["dbram_2048_40bit.v"],
        "resource_usage": {"io":186,"clb":10,"dsp":0,"bram":8,"mult_9x9":0,"other_dsp":0},},
    "module2": {
        "name": "dbram_2048_60bit_module",
        "size":2048,
        "precision":60,
        "inputs":144,
        "outputs":120,
        "filename": ["dbram_2048_60bit.v"],
        "resource_usage": {"io":266,"clb":12,"dsp":0,"bram":12,"mult_9x9":0,"other_dsp":0},},
    "module3": {
        "name": "dbram_4096_40bit_module",
        "size":4096,
        "precision":40,
        "inputs":106,
        "outputs":80,
        "filename": ["dbram_4096_40bit.v"],
        "resource_usage": {"io":188,"clb":7,"dsp":0,"bram":8,"mult_9x9":0,"other_dsp":0},},
    "module4": {
        "name": "dbram_4096_60bit_module",
        "size":4096,
        "precision":60,
        "inputs":146,
        "outputs":120,
        "filename": ["dbram_4096_60bit.v"],
        "resource_usage": {"io":268,"clb":9,"dsp":0,"bram":12,"mult_9x9":0,"other_dsp":0},},
    },
"fifo": {
    "module1": {
        "name": "fifo_256_40bit_module",
        "size":256,
        "precision":40,
        "inputs":43,
        "outputs":42,
        "filename": ["fifo_256_40bit.v"],
        "resource_usage": {"io":87,"clb":4,"dsp":0,"bram":2,"mult_9x9":0,"other_dsp":0},},
    "module2": {
        "name": "fifo_256_60bit_module",
        "size":256,
        "precision":60,
        "inputs":63,
        "outputs":62,
        "filename": ["fifo_256_60bit.v"],
        "resource_usage": {"io":127,"clb":4,"dsp":0,"bram":3,"mult_9x9":0,"other_dsp":0},},
    "module3": {
        "name": "fifo_512_40bit_module",
        "size":512,
        "precision":40,
        "inputs":43,
        "outputs":42,
        "filename": ["fifo_512_40bit.v"],
        "resource_usage": {"io":87,"clb":5,"dsp":0,"bram":2,"mult_9x9":0,"other_dsp":0},},
    "module4": {
        "name": "fifo_512_60bit_module",
        "size":512,
        "precision":60,
        "inputs":63,
        "outputs":62,
        "filename": ["fifo_512_60bit.v"],
        "resource_usage": {"io":127,"clb":5,"dsp":0,"bram":3,"mult_9x9":0,"other_dsp":0},},
    },
"dsp_chain": {
    "module1": {
        "name": "dsp_chain_2_int_sop_2_module",
        "size":2,
        "precision":18,
        "inputs":148,
        "outputs":37,
        "filename": ["dsp_chain_2_int_sop_2.v"],
        "resource_usage": {"io":185,"clb":3,"dsp":2,"bram":0,"mult_9x9":0,"other_dsp":2},},
    "module2": {
        "name": "dsp_chain_3_int_sop_2_module",
        "size":3,
        "precision":18,
        "inputs":222,
        "outputs":37,
        "filename": ["dsp_chain_3_int_sop_2.v"],
        "resource_usage": {"io":259,"clb":4,"dsp":3,"bram":0,"mult_9x9":0,"other_dsp":3},},
    "module3": {
        "name": "dsp_chain_4_int_sop_2_module",
        "size":4,
        "precision":18,
        "inputs":296,
        "outputs":37,
        "filename": ["dsp_chain_4_int_sop_2.v"],
        "resource_usage": {"io":333,"clb":5,"dsp":4,"bram":0,"mult_9x9":0,"other_dsp":4},},
    "module4": {
        "name": "dsp_chain_2_fp16_sop2_mult_module",
        "size":2,
        "precision":"fp16",
        "inputs":128,
        "outputs":32,
        "filename": ["dsp_chain_2_fp16_sop2_mult.v"],
        "resource_usage": {"io":160,"clb":3,"dsp":2,"bram":0,"mult_9x9":0,"other_dsp":2},},
    "module5": {
        "name": "dsp_chain_3_fp16_sop2_mult_module",
        "size":3,
        "precision":"fp16",
        "inputs":192,
        "outputs":32,
        "filename": ["dsp_chain_3_fp16_sop2_mult.v"],
        "resource_usage": {"io":224,"clb":4,"dsp":3,"bram":0,"mult_9x9":0,"other_dsp":3},},
    "module6": {
        "name": "dsp_chain_4_fp16_sop2_mult_module",
        "size":4,
        "precision":"fp16",
        "inputs":256,
        "outputs":32,
        "filename": ["dsp_chain_4_fp16_sop2_mult.v"],
        "resource_usage": {"io":288,"clb":5,"dsp":4,"bram":0,"mult_9x9":0,"other_dsp":4},}
    }
}

select_hardware(module_dict,resources_dict,hardware_dict,seed,threshold)

