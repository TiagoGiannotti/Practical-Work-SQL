# Practical Work

## First Part

### Instructions

After deciding on a relational database engine (we recommend SQL Server to apply what will be covered in unit 3, but you may choose another as long as it is relational if you prefer), it's time to create the database.

You must install the DBMS and document the process. Do not include screenshots. Detail the applied configurations (file locations, allocated memory, security, ports, etc.) in a document as you would present to the DBA.

Create the database, entities, and relationships. Include constraints and keys. You must submit a `.sql` file with the complete creation script (it should work if executed "as is"). Include comments to indicate what each code module does.

Generate Stored Procedures to handle insertion, modification, deletion (if applicable, you should also decide if certain entities will only allow logical deletion) of each table.

The names of the Stored Procedures **SHOULD NOT** start with "SP". Generate schemas to logically organize the system components and apply this in object creation. **DO NOT** use the "dbo" schema.

The `.sql` file with the script must include comments containing these instructions, the submission date, group number, subject name, and the names and ID numbers of the students.

A database model is presented to be implemented by Cure SA hospital for scheduling medical appointments and viewing completed clinical studies. The model is as follows:

![Database Model](https://github.com/hozlucas28/SQL-Server-Course-II-2023/blob/Master/.github/der.png?raw=true)

To facilitate reading the diagram, the identification of the cardinality in the relationships is provided:

![Cardinality Identification](https://github.com/hozlucas28/SQL-Server-Course-II-2023/blob/Master/.github/cardinality-identification.png?raw=true)

#### Clarifications:

- The model is the initial schema; if necessary, add relationships/entities as appropriate.
- Appointments for clinical studies are outside the scope of the current system development.
- Clinical studies are entered into the system by the technician responsible for performing the study, once the study is completed (in the case of images) and in the case of laboratories when it is finished.
- Medical appointment slots have an initial status of available, depending on the doctor, specialty, and location.
- The providers consist of Social Security and Private Health Insurance with which a commercial alliance is established. This alliance can end at any time, so it must be immediately updatable if the contract is not in force. If the contract is not in force, all patient appointments linked to that provider must be canceled and reverted to available status.
- Clinical studies must be authorized, indicating whether the full cost is covered or only a percentage. The Cure system communicates with the provider's service, sending the study code, patient's ID number, and plan; the provider's system informs whether it is authorized and the amount to be billed to the patient.

The roles established at the beginning of the project are:

- Patient
- Doctor
- Administrative Staff
- Clinical Technical Staff
- General Administrator

> The web user is defined using the ID number.

## Second Part

Masters of Doctors, Patients, Providers, and Locations are provided in CSV format. There is also a JSON file that contains the parameters for the authorization mechanism according to the study and health insurance, as well as the covered percentage, etc. See the "Datasets to Import" file in MIeL.

You are required to import all the aforementioned information into the database. Generate the necessary objects (Stored Procedures, functions, etc.) to import the mentioned files. Note that each month new files with the same structure but new data will be received to add to each master. Consider this behavior when generating the code. It must allow the periodic import of updates.  
The structure/schema of the tables to be generated will be your decision. You may need to perform transformation processes on the received masters to adapt them to the required structure.

The CSV/JSON files should not be modified. If there are incorrectly loaded, incomplete, erroneous, etc., data, you should handle and correct them in the SQL source. (An exception would be if the file is malformed and cannot be interpreted as JSON or CSV). Document the corrections you make, indicating the line number, previous content, and new content. This will be checked to verify that the instructions are correctly followed.  
Additionally, the system must be able to generate an XML file detailing the attended appointments to inform the Health Insurance. It should include the patient's data (Last name, first name, ID number), the name and registration number of the attending professional, date, time, specialty. The input parameters are the name of the health insurance and a date range.  
You must submit a `.sql` file with the script to create the corresponding objects. Include a comment in the same file containing these instructions, the submission date, group number, subject name, and the names and ID numbers of the students. The same SQL file must allow the generation of the objects outlined in this delivery (it should allow a complete execution without errors).
