./omnimeter/lib/windows/nssm install OmniMeter2  C:\Users\bryan\OneDrive\Documentos\omnimeter\python3.7.9\python.exe
./omnimeter/lib/windows/nssm set OmniMeter2 AppParameters main.py
./omnimeter/lib/windows/nssm set OmniMeter2 AppDirectory C:\Users\bryan\OneDrive\Documentos\omnimeter\server\omnimeter\
./omnimeter/lib/windows/nssm set OmniMeter2 Description "Measures things everywhere"
./omnimeter/lib/windows/nssm set OmniMeter2 AppPriority IDLE_PRIORITY_CLASS