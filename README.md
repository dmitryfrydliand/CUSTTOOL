# CUSTTOOL
SAP Customizing Documentation tool

Quite often customers request documentation of the entire customization effort made during the implementation and especially the PoC projects. Not talking about how useful it is but nevertheless document is a part of the contract and must be delivered.

Not sure how many times you faced it – this happened quite often to me and consumed a lot of my time.

How did we solve this normally? I did the stupid monkey routine of taking hundreds of screenshots based on what I remember I customized, sometimes also checking customizing transport requests to remind myself what I’ve done.

That's how I came to the idea that this should have already been automated. If transport requests have all the changes we made, there should be a way to download such a report.  But, really? I have not found anything, neither in Google nor in SCN/SolMan.

So we at decided to create this solution ourselves and share it with the community.
 
Some answers to the questions you might already have:

What is this solution? It’s an SAP GUI report designed to be executed in SE38. It takes customizing transports (released tasks!) and Microsoft Word (project) template as an input and produces another MS Word document containing all the customized entries with descriptions as an output.

How I can install it?  
1.	Download the code and the template from either GitHub or here 
2.	Create a report ZREP_CUST_DOC on your NetWeaver system in transaction SE38 
3.	Copy the code into the report and activate it. 

MS Word template has its own instructions how to change the logo and customer/project names.

How does it work? We reused the SAPLink source code (thanks to them) to get the content of the customizing transports, then the solution selects the complete entry from the customizing table/view, reads all the fields/table/view descriptions from DDIC in the given language and downloads all the information in a readable way to the MS Word document as per template provided by the user.

Is it safe to install? Yes, as you can audit the code before installation. Also, please only create the report in the development/customizing system and never in a production environment.

What NetWeaver versions are supported? I hope everything from 7.0, maybe even below.

Any functional prerequisites, would it work on ERP/SCM/PLM etc. systems? This will work everywhere. And there are no functional prerequisites.

Are there any restrictions? Unfortunately, due to MS Word limitations, we only show the first 10 columns of the customized entry in the final document. However, in most cases it is sufficient.

Can I use this freely? Yes, but we would highly appreciate the feedback and reviews.

Do you plan to support the report? Why not, if you have any ideas what needs to be extended, or see any bugs, please let me know.

What does the template look like? See the screenshots or download the template.

What does the result look like? See the screenshots or download the example file.



