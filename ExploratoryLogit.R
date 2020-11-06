#!/usr/bin/env Rscript
# Copyright (c) 2015. All rights reserved.
####################################################################################################
# Proj: Business Analytics Assignment 5
# Desc: Logistic regression on all features.
# Auth: Gaegauf Luca, Salamanca Daniel
# Date: 2015/12/14
####################################################################################################
# Clear environment
rm(list = ls())
.libPaths(c( .libPaths(), "~/LucaLibrary"))

# Set up workspace 
setwd("/Users/LucaPuppy/Documents/Uni Economics/M_Semester_9/Business_Analytics/EX5/Eclipse")

# Load libraries
library(data.table)

# Read data
dt.input <- fread(input = "outputFile.csv", header = FALSE, 
                  col.names = make.names(c("id", "fixed", "reopened", "successRateAssignee", "timeOpened",
                                "successRateReporter", "assignmentNumber", "editionNumber",
                                "P1", "P2", "P3", "P4", "P5", "blocker", "critical", "enhancement",
                                "major", "minor", "trivial", "0 DD 0.9", "0 DD 1.0", "0 DD 1.1", "0.1",
                                "0.1.3", "0.2", "0.5", "0.5.0", "0.6", "0.7", "0.7.1", "0.8", "0.8.0",
                                "0.9", "0.9.2", "1.0", "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.1",
                                "1.1.0", "1.1.1", "1.1.3", "1.2", "1.2.0", "1.2.1", "1.3.0", "1.3.1",
                                "1.5", "1.5.2", "1.5.3", "1.5.4", "1.5.5", "1.7", "1.7.1", "1.8", "2.0",
                                "2.0.0", "2.0.1", "2.0.2", "2.0.3", "2.1", "2.1.0", "2.1.1", "2.1.2",
                                "2.1.3", "2.2", "2.2.1", "2.3", "2.3.0", "2.3.1", "2.4.0", "2.5.0",
                                "2.6.0", "2.7.0", "2008.Ganymede", "3.0", "3.0.0", "3.0.1", "3.0.2",
                                "3.0.3", "3.0.5", "3.1", "3.1.1", "3.1.2", "3.2", "3.2.1", "3.2.2",
                                "3.3", "3.3.1", "3.3.2", "3.4", "3.4.1", "3.4.2", "3.5", "3.5.1",
                                "3.5.2", "3.6", "3.6.1", "3.6.2", "3.7", "4.0", "4.0.1", "4.0.2",
                                "4.0.3", "4.1", "4.2", "4.2.2", "4.3", "4.4", "4.5", "4.6", "4.7",
                                "5.0", "5.0.1", "5.0.2", "6.0", "6.0.1", "6.0.2", "6.1", "7.0", "7.0.1",
                                "7.0.2", "8.0", "DD 0.9", "DD 1.0", "DD 1.1", "Europa", "Galileo",
                                "dev", "unspecified", "AI", "API Tools", "APT", "ASF.Runtime", "ATL.UI",
                                "All", "Annotations", "Ant", "App", "Architecture Council", "Articles",
                                "Autotools", "Bugzilla", "Build", "Build.Web", "Bundles", "CDE",
                                "CDT.Contrib", "CDT.parser", "CDateTime", "CME", "CVS", "Callisto",
                                "Cell", "Chart", "Code Assist", "Codegen", "CommitterTools", "Compare",
                                "Compendium", "Components", "CompositeTable", 
                                "Connection Mgt Framework", "Connectivity", "Core", "Cpp.Extensions", 
                                "Cross.Project","Cross.project", "DD", "DOC", "DSF", "Data Source Explorer",
                                "DataTools", "Debug", "Debug.MI", "Debug.UI", "Debugger", "Demo",
                                "Desktop", "DevTools", "Doc", "Docs", "Documentation", 
                                "Dynamic Plugins", "EEF", "EclipseBot", "EclipseCon", "Edit", "Editor",
                                "EnglishStrings", "Examples", "FAQ", "Faceted Project Framework",
                                "Forums and Newsgroups", "Foundation", "Framework", "GDB", "GEF",
                                "General", "General UI", "Generic.Extensions", "Help", "Hudson",
                                "Hyadess", "IDE", "IPZilla", "Incubatorr", "Incubators", "Intro", 
                                "J2EE Standard Tools", "JET", "JFC.Swing", "JFace", "Java", "Java Core", 
                                "Java Model .JEM", "Javaco", "Jet", "Jira", "LPEX", "Launcher",
                                "LinuxDistros", "MI", "MTJ projects", "Mapping", "Marketplace",
                                "Memory", "Models . Graphical", "Monitor.UI", "Monitor.UI.GLARules",
                                "Monitor.UI.SDBEditor", "Mozilla", "Newsgroups", "OAW", "OSGi", 
                                "Outline Views", "PHP Explorer View", "PHP Search", "PLDT", "PMC", "Phoenixx",
                                "Platform.Analysis", "Platform.Collection", "Platform.Communication",
                                "Platform.Execution", "Platform.LineCoverage.Runtime", "Platform.Model",
                                "Platform.UI", "Platform.UI.ProfilingPerspective",
                                "Platform.UI.SequenceDiagram", "Platform.UI.StatsPerfViewers",
                                "Plugins", "Portal", "Prereq", "Problems view", "Process", 
                                "Project Management", "RDT", "RSE", "Releng", "Report", "Report Designer",
                                "Report Viewer", "Repository", "Resources", "Runtime", "Runtime Common",
                                "Runtime Diagram", "SQL Editor Framework", "SQLDevTools", "SWT",
                                "SWTBott", "Scripting", "Search", "Security", "Server", "Server.Side",
                                "TM", "Table Data Editor", "Tasks", "Team", "Teneo", "Test.Agents",
                                "Test.Execution", "Test.Execution.JUnitRunner", "Test.UI",
                                "Test.UI.JUnit", "Test.UI.Reporting", "Test.http", "Text", "Toolss",
                                "Trac", "Trace.UI", "UI", "UI Guidelines", "UML", "UML22", "Unspecified",
                                "Update", "Update  .deprecated . use RT>Equinox>p2", "Update Site",
                                "Updater", "User", "User Assistance", "Utils", "VCM", "Visualization",
                                "Web Server .Apache", "Web Standard Tools", "WebDAV", "Website",
                                "Workbench", "Xtext", "accservice", "alf.core", "alf.tools",
                                "apps.eclipse.org", "bundles", "cdt.build", "cdt.build.managed",
                                "cdt.codan", "cdt.core", "cdt.cppunit", "cdt.debug", "cdt.debug.cdi",
                                "cdt.debug.cdi.gdb", "cdt.debug.dsf", "cdt.debug.dsf.gdb",
                                "cdt.debug.edc", "cdt.doc", "cdt.editor", "cdt.indexer", "cdt.launch",
                                "cdt.memory", "cdt.other", "cdt.parser", "cdt.refactoring",
                                "cdt.releng", "cdt.source.nav", "core", "cpp.package", "deprecated2",
                                "deprecated3", "deprecated4", "deprecated5", "deprecated6",
                                "deprecated7", "documentation", "draw2d", "e44", "eJFace", "eSWT",
                                "eWorkbench", "ecf.core", "ecf.doc", "ecf.filetransfer", "geclipse",
                                "java.package", "jee.package", "jst.ejb", "jst.j2ee", "jst.jsp",
                                "jst.server", "jst.servlet", "jst.ws", "mozide", "newsgroups",
                                "org.eclipse.stp.bpmn", "p2", "package content", "releng", "tools",
                                "translations", "ufacekit", "ui", "wizard", "wst.common", "wst.css",
                                "wst.html", "wst.internet", "wst.javascript", "wst.jsdt", "wst.server",
                                "wst.sse", "wst.web", "wst.ws", "wst.wsdl", "wst.xml", "wst.xsd",
                                "wtp.inc.jpaeditor", "ACTF", "AJDT", "ALF", "ATF", "Amalgam", "AspectJ",
                                "BIRT", "Babel", "CDT", "CMEE", "Community", "DDD", "DSDP", 
                                "Dali JPA Tools", "Dash Athena", "Data Tools", "E4", "ECF", "EGit", "EMF", "EMFT",
                                "EPP", "EPS.EclipseLink", "ERCP", "EclipseLink", "Equinox", "GEFF",
                                "GMF", "GMP", "GMT", "Higgins", "Hyades", "Incubator", "JDT", "JSDT",
                                "JWT", "Java Server Faces", "Kepler", "Linux Distros", "Linux Tools",
                                "M2M", "M2T", "MDT", "MPC", "MTJ", "Modeling", "Mylar", "Mylyn", 
                                "Mylyn Tasks", "Nebula", "Orbit", "PDE", "PDT", "PTP", "Phoenix", "Platform",
                                "RAP", "Riena", "SOA", "SOC", "SWTBot", "Simultaneous Release",
                                "Spaces", "Stellation", "Subversive", "TMF", "TPTP", "TPTP ASF", 
                                "TPTP Line Coverage", "TPTP Log Analyzer", "TPTP Profiling", 
                                "TPTP Release Engineering", "TPTP Testing", "Target Management", "Tools", "UML2",
                                "VE", "WTP Common Tools", "WTP EJB Tools", "WTP Incubator", "WTP Java EE Tools", 
                                "WTP Releng", "WTP ServerTools", "WTP Source Editing", 
                                "WTP Webservices", "Web Tools", "XSD", "e4", "gEclipse", "m2e", "z_Archived",
                                "AIX GTK", "AIX Motif", "Alll", "HP.UX", "Linux", "Linux Qt",
                                "Linux.GTK", "Linux.Motif", "Mac OS", "Mac OS X", "Mac OS X . Cocoa",
                                "MacOS X", "Neutrino", "Other", "QNX.Photon", "Solaris", "Solaris.GTK",
                                "Solaris.Motif", "Symbian Qt", "SymbianOS S60", "SymbianOS.Series 80",
                                "Unix All", "Windows 2000", "Windows 2003 Server", "Windows 7", 
                                "Windows 95", "Windows 98", "Windows All", "Windows CE", "Windows ME", 
                                "Windows Me", "Windows Mobile 2003", "Windows Mobile 5.0", "Windows NT", 
                                "Windows Server 2003", "Windows Server 2008", "Windows Vista", 
                                "Windows Vista Beta 2", "Windows Vista.WPF", "Windows XP", "other", "out")))


# Format data -------------------------------------------------------------
dt.input[, out := NULL]

# Convert dummies to factors
dt.input$fixed <- as.factor(make.names(dt.input$fixed))
for(i in names(dt.input)[9:ncol(dt.input)]){
  dt.input[[i]] <- as.factor(make.names(dt.input[[i]]))
}
rm(i)
str(dt.input)

# Check the balance of the label
prop.table(table(dt.input$fixed))

# Set the DV variable and the id variable name
DV.var <- "fixed"
ID.var <- "id"

# Data sampling -----------------------------------------------------------
set.seed(123457)
train_ind <- createDataPartition(dt.input[[DV.var]], p = 0.6, list = FALSE)
trainset <- dt.input[train_ind, ]
testset <- dt.input[-train_ind, ]

# Determine the features with too few levels (dependent on how the data is sampled)
varWithtooFewLevs <- names(trainset)[which(lapply(trainset, FUN = function(x) length(unique(x)))==1)]

# Set the training formula
formu <- fixed ~ . - fixed 

# Run logistic regression
log.model <- glm(formu, data = trainset[, !(names(testset) %in% c(ID.var, varWithtooFewLevs)), with = FALSE], 
                 family = binomial(link = 'logit'))

summary(log.model)
