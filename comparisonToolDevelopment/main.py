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
        result = pyergo_query('final.')
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

def aspKnolwedgeBase():
    file_path = r"C:\Users\ArunRAVEENDRANNAIRSH\Desktop\VritualAssistant\comparisonToolDevelopment\asp.pl"
    file = open(file_path, "r")
    file_content = file.read()
    file.close()

    class Context:
        pass

    def on_model(m):
        print(m)

    ctl = clingo.Control()
    ctl.add("base", [], file_content)
    ctl.ground([("base", [])], context=Context())
    ctl.solve(on_model=on_model)

def iterate_function_horn_logic(num_iterations):
    delaysHornLogic = []
    for _ in range(num_iterations):
        start_time = time.time()
        hornLogicKnowledgeBase()
        end_time = time.time()
        delay = end_time - start_time
        delaysHornLogic.append(delay)
    return delaysHornLogic

def iterate_function_ASP(num_iterations):
    delaysASP = []
    for _ in range(num_iterations):
        start_time = time.time()
        aspKnolwedgeBase()
        end_time = time.time()
        delay = end_time - start_time
        delaysASP.append(delay)
    return delaysASP

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


num_iterations = 20
all_data = [iterate_function_horn_logic(num_iterations),iterate_function_ASP(num_iterations), iterate_function_OWL(num_iterations),iterate_function_Flogic(num_iterations)]

pyergo_end_session()

# Define colors for each box plot
colors = ['lightblue', 'lightgreen', 'lightpink', 'red']

# Create a figure and axis
fig, ax = plt.subplots()

# Create box plots for each data set with custom colors
boxplot = ax.boxplot(all_data, patch_artist=True)

# Set box colors
for patch, color in zip(boxplot['boxes'], colors):
    patch.set_facecolor(color)

averages = [np.mean(data) for data in all_data]
for i, avg in enumerate(averages):
    ax.text(i + 1, avg, f'    {avg:.2f}', ha='left', va='top')
# Set x-axis tick labels
ax.set_xticklabels(['Horn Logic', 'ASP', "OWL","F-Logic"])

# Set labels and title
ax.set_ylabel('Value')
ax.set_title('Response Time Mean for 100 iterations')

# Show the plot
plt.show()

