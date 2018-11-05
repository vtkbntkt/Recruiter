sfdx force:org:list

sfdx force:org:delete -u RecruiterApp2
sfdx force:org:create -f -s config/project-scratch-def.json -a RecruiterApp2 --durationdays 30
sfdx force:org:create -f -s config/project-scratch-def.json -a RecruiterApp2
sfdx force:source:push -u RecruiterApp2
sfdx force:source:push -u -f RecruiterApp2
sfdx force:data:tree:import --sobjecttreefiles data/<>.json
sfdx force:user:permset:assign -n Recruiter -u RecruiterApp2
sfdx force:org:open -u RecruiterApp2
sfdx force:source:pull -u RecruiterApp2
