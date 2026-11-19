*This project has been created as part of the 42 curriculum by Matteo Winter (mattwint), Antoine Lubrano (alubrano), Refih Can (recan) and Lucie Simon (lusimon).* 

## Description

**Project goal:** This project implements a Retrieval-Augmented Generation (RAG) system that connects a Large Language Model (LLM) to a company's internal database, giving employees an AI assistant that simplifies their daily workflow.

**Overview:** When an employee submits a question, the system automatically generates a retrieval query behind the scenes, fetches the relevant information from the company database, and passes it to the LLM, which analyzes it and produces a complete, contextualized answer. The employee gets a clear response without having to search through documents manually.

**Access control:** Since not every employee should have access to every document, the system enforces permission-based retrieval. Results are filtered according to the identity and access rights of the authenticated user, so the LLM only ever sees (and answers from) data that the user is authorized to view.

## Resources

### PostgreSQL database + pgAdmin

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Crash Course – Beginner Tutorial](https://www.youtube.com/watch?v=gySEbKmkvEU)
- [pgAdmin – the PostgreSQL management tool](https://www.pgadmin.org/)

### ER diagram

- *Database Design for Mere Mortals* by Michael J. Hernandez (book on relational database design)
- [Lucidchart](https://lucid.app/) – to create Entity-Relationship Diagram online

### Constrained decoding / JSON Schema

- [Structured Outputs: Reliable JSON from an LLM](https://www.youtube.com/watch?v=HG3dmLAE_jM&t=364s)
