#make jupyter setting file
cd ${HOME}
jupyter notebook --generate-config

#save default setting as ".old"
cp ${HOME}/.jupyter/jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py.old
#copy setting for open access
cp ${HOME}/src/jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py

#set password
echo 'SET PASSWORD FOR JUPYTER NOTEBOOK'
PASSWD=$(python3.9 -c 'from notebook.auth import passwd;print(passwd())' | tee /dev/tty)
if [ "`echo $PASSWD | grep 'Passwords do not match'`" ]; then
  echo "RETRY: please run \"~/src/set_jupyer.sh\" again"
else
  echo c.NotebookApp.password=\'${PASSWD}\' >> ${HOME}/.jupyter/jupyter_notebook_config.py
  echo "DONE: run \"jupyter notebook\" or \"jupyter lab\""
fi
