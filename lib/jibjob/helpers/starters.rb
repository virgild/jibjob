# coding: utf-8

module JibJob
  module Helpers
    module StarterHelper
      def resume_starter
        <<-EOR
#N Thomas B. Seeker
#A 1234 Northern Star Circle
#A Baltimore, MD 12345
#T (410) 555-1212
#E seeker@nettcom.com
#U http://nettcom.com/tseeker

= Career Goal
---
Client Server Systems Architect for a high technology firm
---

= Qualifications Summary
---
Nine years of experience in designing, installing, and troubleshooting 
computing systems; a proven track record in identifying problems and 
developing innovative solutions.
---

- PROGRAMMING: C, C++, Visual BASIC, FORTRAN, Pascal, SQL, OSF/Motif
- OPERATING SYSTEMS: UNIX (bsd & SVr3/r4), MS Windows, MS DOS, MS Windows NT
- NETWORKING: TCP/IP, OSI, Microsoft LAN Manager, Novell Netware
- APPLICATIONS: Microsoft Office, Microsoft Access, Microsoft Visual C++, 
  Microsoft Project

= Work Experience
+ Systems Engineer
>O Computer Engineering Corporation
>L Los Angeles, CA
>D 1993 to Present
- Provide systems engineering, software engineering as a member of the Systems Integration Division of a software engineering consulting company.
- Designed and managed the development of an enterprise-level client/server automated auditing application for a major financial management company.
- Designed an enterprise level, high performance, mission-critical, client/server database system incorporating symmetric multiprocessing computers (SMP)

+ Systems Analyst
>O Business Consultants, Inc.
>L Washington, DC
>D 1990 to 1993
- Provided technical consulting services to the Smithsonian Institute's Information Technology Services Group, Amnesty International, and internal research and development initiatives.
- Consolidated and documented the Smithsonian Laboratory's Testing, Demonstration, and Training databases onto a single server, maximizing the use of the laboratory's computing resources.

= Education
+ Computer Systems Technology Program
>O Air Force Institute of Technology (AFIT)

+ BS, Mathematics/Computer Science
>O University of California, Los Angeles (UCLA)
EOR
      end
    end
  end
end