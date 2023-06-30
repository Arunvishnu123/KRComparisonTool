import time
import matplotlib.pyplot as plt
from pyswip import Prolog
import clingo
import numpy as np
from owlready2 import *

ERGOROOT = "C:/Users/ArunRAVEENDRANNAIRSH/Coherent/ERGOAI-3.0/ErgoEngine/ErgoAI"
XSBARCHDIR = "C:/Users/ArunRAVEENDRANNAIRSH/Coherent/ERGOAI-3.0/XSB/config/x64-pc-windows"

import sys


sys.path.append(ERGOROOT.replace('\\','/') + '/python')

from pyergo import \
pyergo_start_session, pyergo_end_session, \
pyergo_command, pyergo_query, \
HILOGFunctor, PROLOGFunctor, \
ERGOVariable, ERGOString, ERGOIRI, ERGOSymbol, \
ERGOIRI, ERGOCharlist, ERGODatetime, ERGODuration, ERGOUserDatatype, \
pyxsb_query, pyxsb_command, \
XSBFunctor, XSBVariable, XSBAtom, XSBString, \
PYERGOException, PYXSBException

pyergo_start_session(XSBARCHDIR,ERGOROOT)

def floraReasoner():
    try:
        pyergo_command("['C:/Users/ArunRAVEENDRANNAIRSH/Desktop/VritualAssistant/comparisonToolDevelopment/flogic.flr'].")
        result = pyergo_query('findRunways(?AirportName, ?RunwayName, ?Distance ).')
    except:
        pass



def owlReasoningSystem():
    # Load the ontology
    try:
      onto = get_ontology(r"C:\Users\ArunRAVEENDRANNAIRSH\Desktop\VritualAssistant\comparisonToolDevelopment\dl.owl").load()

     # Initialize the reasoner
      with onto:
        sync_reasoner_pellet()

     # Check consistency
      if not onto.reasoning_owlready:
        print("The ontology is consistent.")
      else:
        print("The ontology is inconsistent.")
    except:
        pass
def hornLogicKnowledgeBase():
    prolog = Prolog()

    start = time.process_time()
    prolog.consult(r"knowledgebase.pl")
    print(list(prolog.query("finalPredicate")))


def iterate_function_horn_logic(num_iterations):
    delaysHornLogic = []
    for _ in range(num_iterations):
        start_time = time.time()
        hornLogicKnowledgeBase()
        end_time = time.time()
        delay = end_time - start_time
        delaysHornLogic.append(delay)
    return delaysHornLogic





def iterate_function_OWL(num_iterations):
    delaysOWL = []
    for _ in range(num_iterations):
        start_time = time.time()
        owlReasoningSystem()
        end_time = time.time()
        delay = end_time - start_time
        delaysOWL.append(delay)
    return delaysOWL

def iterate_function_Flogic(num_iterations):
    delaysOWL = []
    for _ in range(num_iterations):
        start_time = time.time()
        floraReasoner()
        end_time = time.time()
        delay = end_time - start_time
        delaysOWL.append(delay)
    return delaysOWL


num_iterations =  100
all_data = [iterate_function_horn_logic(num_iterations), iterate_function_OWL(num_iterations),iterate_function_Flogic(num_iterations)]

pyergo_end_session()

# Define colors for each box plot
colors = ['blue', 'blue', 'blue']

# Create a figure and axis
fig, ax = plt.subplots()
# Calculate the statistical values for each data set
statistics = [np.mean(data) for data in all_data]
# Create bar graphs for each data set with custom colors
bars = ax.bar(np.arange(len(all_data)), statistics, color=colors)

# Set x-axis tick labels
ax.set_xticks(np.arange(len(all_data)))
ax.set_xticklabels(['Horn Logic', "OWL","F-Logic"])

# Set labels and title
ax.set_ylabel('Time Delay')
ax.set_title('Diversion Use Case - Response time mean for 100 iterations')

# Add values above each bar
for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width() / 2, height, f'{height:.2f}', ha='center', va='bottom')

# Show the plot
plt.show()

