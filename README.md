# Conception of an Optimization Tool in a Logistics Company

## Presentation

This project was developed as part of a Master 1 MIASHS Research and Study Project (TER) in Computer Science and Cognition at Université Grenoble Alpes. It proposes the design of a tool to optimize logistics processes within a company. 

Based on our discussions with Ms. Landry and Ms. Sicco, the company processes approximately 600 orders per day, typically distributed among operators who each handle about 30 orders per day. The current logistics process is as follows: receiving homogeneous and heterogeneous pallets (mixed products), sorting and storing them by building homogeneous pallets from heterogeneous ones, and placing them in warehouse storage in so-called "rack" zones. Workers then perform picking of various items to create heterogeneous pallets according to customer orders. Today, the company considers its current productivity insufficient, and ergonomics can be improved to reduce workplace accidents. Using field analyses and data collected, our project provides suggestions to optimize the organization of picking processes performed by workers while integrating ergonomic aspects to protect their occupational health.

Our project aims to analyze the current situation and provide suggestions to optimize the company's operations and the employees' working environment.

To meet our requirements, we used the LPG Solver in PDDL language, capable of finding solutions based on hard and/or soft constraints. The objectives of the tool were to satisfy a maximum number of constraints for each solution and allow testing of constraint scenarios. 

## Project Objectives

- Analyze the company's current logistics process to identify its limitations and areas for improvement.
- Model the various process steps (reception, storage, order preparation) using PDDL.
- Use the LPG solver to generate optimized plans based on defined constraints.
- Evaluate current productivity and propose improvement pathways to achieve production targets (approx. 600 orders per day).
- Study ergonomic optimization possibilities to reduce the risks of workplace accidents.
- Test various hard and soft constraint scenarios to compare proposed solutions.
- Analyze the impact of process modifications on overall efficiency and work organization.

## Project Workflow

The project generates several domain files that model the logistics process. Information regarding this process was gathered through observations by PhD student Alexandra Sicco. These domain files aim to replicate the functioning of the process as well as all possible agents, objects, and actions.

Problem files describe different initial environments and define precise objectives to achieve. Once processed by the solver, they produce an optimized sequence of actions to reach these objectives as efficiently as possible.

In our Git repository, you will find the domain files. Each file is commented to clearly present its functionalities, defined actions, and object types used, making the system's operation easy to understand. Problem files, often named p00x.pddl, are similarly documented to ensure readability and comprehension.

By analyzing the resulting steps proposed by the solver, we are able to identify process weaknesses, highlight new cost-reduction opportunities, and evaluate the ergonomic impact of different solutions.

## Technologies Used
- Main language: **PDDL**
- Solver: **LPG**
- Environment: **Local only** (no database or remote server)

**LPG**: The solver is an algorithm specialized in solving complex constraint satisfaction problems. It is capable of optimizing solutions according to defined priorities. The project uses LPG, an open-source solver renowned for its robustness and efficiency in managing complex constraints.

**PDDL**: (Planning Domain Definition Language) is a standard language used in artificial intelligence to describe automated planning problems. It allows defining a domain—comprising possible actions and their effects—as well as a specific problem with an initial state and a goal to achieve. Thanks to this formal representation, planners can automatically generate a sequence of actions to solve the problem efficiently.

In PDDL, a planning task is described using two files: a domain file and a problem file. The domain file defines general rules of the environment, such as predicates and available actions, while the problem file specifies a particular situation with objects, an initial state, and a target goal. The planner uses both files to automatically generate a plan to reach the goal.

## Project Guide

### 1. Branches
- **one_model_iterations**: The model development process, integrating all processes of a single domain, is presented here. It includes six iterations of progressively increasing complexity. The first five iterations are functional.
- **Preparation_command**: Displays the iterations prior to obtaining the functional version of the order preparation model.
- **Tests**: Displays the initial models created in PDDL.
- **Pallet Receiving**: The functional version of the pallet arrival model in the warehouse.

### 2. Files
- **Documents**: All documentation produced within the framework of our project.
- **Process 1: Pallet Receiving**: The functional version of the pallet reception model and the sorting of mono & mixed pallets.
- **Process 2: Command Prep**: The functional version of the order preparation model.

## Installation - PDDL Project with LPG-td

### 1. Prerequisites
- **Operating System**: Windows, Linux (Debian recommended for native compatibility).
- **Terminal**: Access to a terminal (bash, PowerShell, etc.).
- **Solver**: `lpg-td` executable (downloaded and extracted in the project directory) - Consult the `README-LPGTD` file.
- **Optional**: Docker (recommended if you encounter dependency issues on your host system).

### 2. Installation
1. Go to the website https://lpg.unibs.it/lpg/
2. Enter your personal details: email address, name.
3. **Download**: Download the archive matching your system:
   - LPG-td Linux
   - LPG-td Windows
   - Source: https://lpg.unibs.it/lpg/download-lpg-td.html
4. **Extraction**:
   - Under **Linux**, place the archive in your folder and run:
     ```bash
     gunzip lpgtd-linux.tar.gz
     tar xvf lpgtd-linux.tar
     ```
   - Under **Windows**, use a tool like WinZip or 7-Zip to extract the files.
5. **Verification**: Ensure that the `lpg-td` (or `lpg-td.exe`) file is present in the working directory.

**If you need Docker:**

**1. Installing Docker Desktop**
1. Go to the official page: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/).
2. Download **Docker Desktop for Mac (Apple Silicon)**.
3. Install the `.dmg` file by moving the icon to your **Applications** folder.
4. Open **Docker Desktop** and let the application fully initialize.
5. Restart your computer to ensure proper system tool configuration.

**2. Solver Setup in the Terminal**
1. Uncompress the solver archive:
   `tar -xvf lpgtd-1_4-linux.tar.gz`
   You should obtain a folder named `LPG-td-1.4`. Stay in the parent directory of this folder.
2. Run the command `docker --version` (just to check if docker is installed correctly).
3. Execute:
   `docker run --platform linux/amd64 -it --mount type=bind,source=<ABSOLUTE_PATH_TO_LPG-td-1.4>,target=/LPG-td-1.4 debian:bookworm bash`
   Normally, you should enter a Docker container.
4. Next, if you run:
   `ls /LPG-td-1.4`
   You should see the entire content of your folder. Navigate into the folder using:
   `cd /LPG-td-1.4`
   Then you can run `./lpg-td`.
5. To exit the Docker container, run the `exit` command. To re-enter, repeat the `docker run` command above.

### 3. Cloning the Repository
Open a terminal and execute:
   ```bash
   git clone [https://github.com/abehar9/ProjetTER.git](https://github.com/abehar9/ProjetTER.git)
   cd ProjetTER
   ```

### 4. Usage
To execute the solver, use the following syntax in your terminal:
```bash
./lpg-td -o <domain.pddl> -f <problem.pddl> -n 1
```
Advanced Configuration: Consult the README-LPGTD file.

### 5. Getting Started
To get familiar with the solver, follow these steps:
Initialization: Start with the Process 2: Command Prep/domain_01.pddl and p001.pddl files provided in the folder.
Observation: Run the basic command (-n 1) to observe the output format and solutions proposed by the solver.
Experimentation:
Comparison: Test different problem files to compare solving times.
Analysis: Modify domain files to add complexity (Timed Initial Literals, Derived Predicates) and analyze the impact on search engine performance.
Advanced Configuration: Consult the original README-LPGTD file located in the project folder to adjust search parameters (-noise, -seed, -cputime, etc.) to optimize results according to your specific needs.
Warning: Files ending with '.SOL' are the results generated by the solver.

### 6. Help and Troubleshooting
Permissions: Under Linux, if the file is not recognized as executable, grant the necessary permissions with:
   ```bash
   chmod +x lpg-td
   ```

### Areas for Improvement
Finalization of the Four Process Modeling
To date, only a portion of the processes has been fully modeled. Continuing the project will allow the integration of all four processes to obtain a more complete and coherent representation of the studied system.
Increasing Process 2 Complexity
The second process could be enriched by adding more realistic constraints and scenarios. This evolution would evaluate the model's robustness under conditions closer to real-world operations.
Integration of Ergonomic Factors
Adding ergonomic criteria, such as fatigue, working postures, or operator constraints, would improve the quality of generated plans and better account for the human aspects of the system.
Migration to a Solver Supporting Advanced Numerical Objectives
Using a newer or higher-performance solver would offer the ability to incorporate complex numerical objectives and optimization functions. This would notably help better manage resources, costs, or quantitative performance indicators.

### License
This project was carried out for educational purposes as part of a TER at Université Grenoble Alpes. It may be used, modified, or adapted for non-commercial purposes.

### Authors
Project developed by two students of the Master MIASHS – Université Grenoble Alpes:
Andrea Behar
Anesie Martiniani

### Project Owner / Supervisor:
Ms. Landry Aurélie

### Documentation
The complete documentation, including the installation manual, is available in the docs/ folder.
