import xml.etree.ElementTree as ET
import logging
import pygraphviz as pgv
from typing import Any, Dict, List, Tuple, TypedDict, Annotated

class KTRTransformation():
    def __init__(self):
        self.name: str = ""
        self.order: List[str] = []
        self.steps: List[Step] = []

class Step:
    def __init__(self):
        self.name: str = ""
        self.type: str = ""

class SQLStep(Step):
    def __init__(self):
        super().__init__()
        self.sql: str = ""
        self.parameters: List[Parameter] = []

class Parameter:
    def __init__(self):
        self.name: str = ""
        self.type: str = ""

class FilterStep(Step):
    def __init__(self):
        super().__init__()
        self.send_true_to: str = ""
        self.send_false_to: str = ""
        self.conditions: List[Condition] = []

class Condition:
    def __init__(self):
        self.leftvalue: str = ""
        self.operator: str = ""
        self.rightvalue: str = ""

class InsertUpdateStep(Step):
    def __init__(self):
        super().__init__()
        self.table: str = ""
        self.keys: List[KeyValue] = []
        self.values: List[KeyValue] = []

class KeyValue:
    def __init__(self):
        self.name: str = ""
        self.field: str = ""

def parse_ktr_file(file_path: str) -> KTRTransformation:
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
    except ET.ParseError as e:
        logging.error(f"Error parsing KTR file: {e}")
        raise

    transformation = KTRTransformation()
    
    # Extract transformation name
    transformation.name = root.find("info/name").text

    # Extract order and set active steps
    active_steps = set()
    order_element = root.find("order")
    if order_element is not None:
        for hop in order_element.findall("hop"):
            from_step = hop.find("from").text
            to_step = hop.find("to").text
            transformation.order.append((from_step, to_step))
            active_steps.add(from_step)
            active_steps.add(to_step)            

    # Extract steps
    for step_element in root.findall("step"):
        step_name = step_element.find("name").text
        step_type = step_element.find("type").text

        # Only process steps that are in the active_steps set
        if step_name not in active_steps:
            continue

        if step_type == "DBJoin" or step_type == "TableInput":
            step = SQLStep()
            step.name = step_name
            step.type = step_type
            step.sql = step_element.find("sql").text
            for param in step_element.findall("parameter/field"):
                parameter = Parameter()
                parameter.name = param.find("name").text
                parameter.type = param.find("type").text
                step.parameters.append(parameter)

        elif step_type == "FilterRows":
            step = FilterStep()
            step.name = step_name
            step.type = step_type
            step.send_true_to = step_element.find("send_true_to").text
            step.send_false_to = step_element.find("send_false_to").text
            for condition in step_element.findall("conditions"):
                cond = Condition()
                cond.leftvalue = condition.find("leftvalue").text
                cond.operator = condition.find("function").text
                cond.rightvalue = condition.find("value/text").text
                step.conditions.append(cond)

        elif step_type == "InsertUpdate":
            step = InsertUpdateStep()
            step.name = step_name
            step.type = step_type
            step.table = step_element.find("lookup/table").text
            for key in step_element.findall("lookup/key"):
                kv = KeyValue()
                kv.name = key.find("name").text
                kv.field = key.find("field").text
                step.keys.append(kv)
            for value in step_element.findall("lookup/value"):
                kv = KeyValue()
                kv.name = value.find("name").text
                kv.field = value.find("rename").text
                step.values.append(kv)

        else:
            step = Step()
            step.name = step_name
            step.type = step_type

        transformation.steps.append(step)

    return transformation        

def step_to_markdown(step: Step) -> str:
    md = f"## Step: {step.name}\n\n"
    md += f"Type: {step.type}\n\n"

    if isinstance(step, SQLStep):
        md += "### SQL Query\n\n"
        md += f"```sql\n{step.sql}\n```\n\n"
        if step.parameters:
            md += "Parameters:\n"
            for param in step.parameters:
                md += f"- {param.name} ({param.type})\n"

    elif isinstance(step, FilterStep):
        md += f"Send True To: {step.send_true_to}\n"
        md += f"Send False To: {step.send_false_to}\n\n"
        md += "Conditions:\n"
        for condition in step.conditions:
            md += f"- {condition.leftvalue} {condition.operator} {condition.rightvalue}\n"

    elif isinstance(step, InsertUpdateStep):
        md += f"Table: {step.table}\n\n"
        md += "Keys:\n"
        for key in step.keys:
            md += f"- {key.name}: {key.field}\n"
        md += "\nValues:\n"
        for value in step.values:
            md += f"- {value.name}: {value.field}\n"

    return md

def convert_to_filename(input_string):
    s = re.sub(r'[^a-zA-Z0-9_\-\.~]', '_', input_string)
    return s.lower()


def transformation_to_markdown(transformation: KTRTransformation) -> str:
    md = f"# Transformation: {transformation.name}\n\n"
    md += "## Execution Order\n\n"
    for step_name in transformation.order:
        md += f"- {step_name}\n"
    md += "\n## Steps\n\n"
    for step in transformation.steps:
        md += step_to_markdown(step) + "\n"
    # return md

    md_file_name = convert_to_filename(transformation.name)+'.md'

    try:
        with open(md_file_name, 'w', encoding='utf-8') as f:
            f.write(md)
        logging.info(f"Markdown documentation exported to {md_file_name}")
    except Exception as e:
        logging.error(f"Error exporting markdown to file: {e}")
        raise
    return md

#T = parse_ktr_file(pentaho_file_path)