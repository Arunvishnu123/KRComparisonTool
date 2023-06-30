import time
import matplotlib.pyplot as plt
from pyswip import Prolog
import clingo
import numpy as np
from owlready2 import *
from ortools.sat.python import cp_model



def constraintLogicProgramming():
    prolog = Prolog()

    start = time.process_time()
    prolog.consult(r"clp.pl")
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

def constrainProgramming():
    # Data
    airportDistanceMatrix = [[10000, 800, 900, 1100, 10000, 10000, 10000, 10000, 10000],
                             [10000, 10000, 10000, 10000, 900, 800, 10000, 10000, 10000],
                             [10000, 10000, 10000, 10000, 10000, 700, 10000, 10000, 10000],
                             [10000, 10000, 10000, 10000, 10000, 10000, 950, 10000, 10000],
                             [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 800],
                             [10000, 10000, 10000, 10000, 10000, 10000, 10000, 850, 1200],
                             [10000, 10000, 10000, 10000, 10000, 10000, 10000, 750, 10000],
                             [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 500],
                             [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000]]
    numOfAirports = len(airportDistanceMatrix)

    solver = cp_model.CpModel()

    # Decision Variables
    x = {}
    for i in range(numOfAirports):
        for j in range(numOfAirports):
            x[i, j] = solver.NewBoolVar(f'x[{numOfAirports},{numOfAirports}]')

    # Constraint 1
    for i in range(numOfAirports):
        solver.Add(
            sum([x[i, j] for j in range(numOfAirports)]) - sum([x[j, i] for j in range(numOfAirports)]) == 0)
    # Constraint 2
    solver.Add(sum([x[0, j] for j in range(numOfAirports)]) == 1)
    # Constraint 3
    solver.Add(sum([x[j, 8] for j in range(numOfAirports)]) == 1)

    # Objective function
    objective_terms = []
    for i in range(numOfAirports):
        for j in range(numOfAirports):
            objective_terms.append(airportDistanceMatrix[i][j] * x[i, j])
    solver.Minimize(sum(objective_terms))

    solver1 = cp_model.CpSolver()
    status = solver1.Solve(solver)

    # Print solution.
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print(f'Total cost = {solver1.ObjectiveValue() - 10000}\n')
        for aiport1 in range(numOfAirports):
            for aiport2 in range(numOfAirports):
                if solver1.BooleanValue(x[aiport1, aiport2]) and aiport1 != 8:
                    print(f'Departure Airport  {aiport1}  Arrival Airport {aiport2}.' +
                          f' total distance travelled = {airportDistanceMatrix[aiport1][aiport2]}')
    else:
        print('No solution found.')

def iterate_function_ASP(num_iterations):
    delaysASP = []
    for _ in range(num_iterations):
        start_time = time.time()
        aspKnolwedgeBase()
        end_time = time.time()
        delay = end_time - start_time
        delaysASP.append(delay)
    return delaysASP

def iterate_function_CLP(num_iterations):
    delaysCLP = []
    for _ in range(num_iterations):
        start_time = time.time()
        constraintLogicProgramming()
        end_time = time.time()
        delay = end_time - start_time
        delaysCLP.append(delay)
    return delaysCLP

def iterate_function_ConstrainProgramming(num_iterations):
    delaysCLP = []
    for _ in range(num_iterations):
        start_time = time.time()
        constrainProgramming()
        end_time = time.time()
        delay = end_time - start_time
        delaysCLP.append(delay)
    return delaysCLP



num_iterations =  100
all_data = [iterate_function_ASP(num_iterations),iterate_function_CLP(num_iterations),iterate_function_ConstrainProgramming(num_iterations)]



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
ax.set_xticklabels(['ASP', 'CLP', 'Constraint Programming'])

# Set labels and title
ax.set_ylabel('Time Delay')
ax.set_title('Optimal Route Planning - Response time mean for 100 iterations')

# Add values above each bar
for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width() / 2, height, f'{height:.2f}', ha='center', va='bottom')

# Show the plot
plt.show()

