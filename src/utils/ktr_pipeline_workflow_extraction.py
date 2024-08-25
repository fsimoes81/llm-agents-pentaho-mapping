from langgraph.graph import Graph, Node, Edge
import xml.etree.ElementTree as ET
from typing import List

# Functions for parsing and extracting data from the .ktr file
def parse_ktr_file(file_path: str) -> ET.Element:
    tree = ET.parse(file_path)
    return tree.getroot()

def extract_execution_sequence(root: ET.Element) -> List[str]:
    steps = root.findall(".//step")
    return [step.find("name").text for step in steps]

# Define agent nodes
class KTRParserAgent(Node):
    def run(self, file_path: str) -> ET.Element:
        return parse_ktr_file(file_path)

class ExecutionSequenceAgent(Node):
    def run(self, root: ET.Element) -> List[str]:
        return extract_execution_sequence(root)

# Define the LangGraph pipeline
def create_ktr_pipeline(file_path: str):
    graph = LangGraph()

    # Add nodes
    parser_node = KTRParserAgent(name="KTR Parser Agent")
    sequence_node = ExecutionSequenceAgent(name="Execution Sequence Agent")

    graph.add_node(parser_node)
    graph.add_node(sequence_node)

    # Define edges (dependencies)
    graph.add_edge(Edge(parser_node, sequence_node))

    # Execute the pipeline
    parser_node.set_params(file_path=file_path)
    root_element = parser_node.run()

    sequence_node.set_params(root=root_element)
    execution_sequence = sequence_node.run()

    return execution_sequence

# Example usage:
# file_path = "path_to_your_file.ktr"
# execution_sequence = create_ktr_pipeline(file_path)
# print(execution_sequence)
