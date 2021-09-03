import os
import sys
import json
import re
import hashlib
import traceback
class Attributes(object):
    pass
def usage():
    print("Usage: postprocess_result.py <path> <params>")

def init_attributes(attributes):
    if len(sys.argv) < 2:
        print("ERROR: Missing parameters")
        usage()
        exit(2)
    attributes.test_result_path = sys.argv[1]
    attributes.parameters = sys.argv[2:]

def md5(*args):
    m = hashlib.md5()
    for arg in args:
        part = arg.encode('utf-8')
        m.update(part)
    return m.hexdigest()


def calculate_history_id(feature_name, scenario_name, test_result):
    parts = [feature_name, scenario_name]
    for param in test_result['parameters']:
        param_name = param["name"]
        param_value = param["value"]
        parts.append(f"{param_name}={param_value}")
    return md5(*parts) 


def exists_param(params, param_name):
    for param in params: 
        if param["name"] == param_name:
            return True 
    return False

if __name__ == "__main__":
    try:
        attributes = Attributes()
        init_attributes(attributes)

        param_keywords = ["1. test_language", "2. version", "3. operating system",
                          "4. architecture", "5. docker image"]

        print("Post-processing results")
        print(f"Params: {attributes.parameters}")
        for file in os.listdir(attributes.test_result_path):
            if file.endswith("result.json"):
                with open(f"{attributes.test_result_path}/{file}", 'r+') as f:
                    test_result = json.load(f)
                    params = []
                    if "parameters" in test_result:
                        params = test_result["parameters"]
                    for i in range(len(param_keywords)):
                        if not exists_param(params, param_keywords[i]):
                            new_param = {"name":param_keywords[i], "value": attributes.parameters[i]}
                            params.append(new_param)
                            #print(f"Added parameter: {new_param}")
                    test_result['parameters'] = params
                    labels = test_result["labels"]
                    for label in labels:
                        if label["name"] == "feature":
                            feature_name = label["value"]

                    scenario_name = test_result["name"]

                    # change names
                    test_result["fullName"] = f"{feature_name}: {scenario_name}"

                    add_suite = True
                    add_testClass = True
                    add_story = True
                    story_label = {"name":"story", "value":f"{scenario_name}"}
                    suite_label = {"name":"suite", "value":f"{feature_name}"}
                    testClass_label = {"name":"testClass", "value":f"{scenario_name}"}
                    for label in labels:
                        if label["name"] == "suite":
                            add_suite = False
                            label["value"] = f"{feature_name}"
                        if label["name"] == "testClass":
                            add_testClass = False
                            label["value"] = f"{scenario_name}"
                        if label["name"] == "story":
                            add_story = False
                            label["value"] = f"{scenario_name}"
                    if add_story:
                        test_result["labels"].append(story_label)
                    if add_suite:
                        test_result["labels"].append(suite_label)
                    if add_suite:
                        test_result["labels"].append(testClass_label)

                    # change historyId
                    history_id = calculate_history_id(feature_name, scenario_name, test_result)
                    if "historyId" in test_result:
                        previous_history_id = test_result['historyId']
                    else:
                        previous_history_id = "None"
                    test_result['historyId'] = history_id
                    #if history_id != previous_history_id:
                    #    print(f"Changed history id {previous_history_id} to {history_id}")

                    f.seek(0)        # <--- should reset file position to the beginning.
                    json.dump(test_result, f, indent=4)
                    f.truncate()     # remove remaining part
        print("Results post-processed!")
    except Exception:
        traceback.print_exc()