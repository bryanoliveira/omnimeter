./omnimeter/lib/windows/nssm install OmniMeter2 C:\Users\bryan\AppData\Local\Programs\Python\Python37\python.exe
./omnimeter/lib/windows/nssm set OmniMeter2 AppParameters main.py
./omnimeter/lib/windows/nssm set OmniMeter2 AppDirectory C:\Users\bryan\Documents\Projetos\hw_monitor\server\omnimeter\
./omnimeter/lib/windows/nssm set OmniMeter2 Description "Measures things everywhere"
./omnimeter/lib/windows/nssm set OmniMeter2 AppPriority IDLE_PRIORITY_CLASS