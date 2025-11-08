#!/bin/bash

# Script para monitorear Ansible usando solo pidstat

# Configuración
PIDSTAT_LOG="ansible_create_pidstat.log"
PLAYBOOK="playbooks/deploy_ec2.yml --tags deploy" 

> $PIDSTAT_LOG
> $SUMMARY_LOG

# Lanzar Ansible en background
echo "Iniciando Ansible..."
ansible-playbook $PLAYBOOK &
ANSIBLE_PID=$!
echo "PID de Ansible: $ANSIBLE_PID"

# Monitoreo con pidstat cada 1 segundo mientras corre Ansible
# -u : CPU
# -r : memoria
# -d : I/O de disco
# -h : human readable
pidstat -p $ANSIBLE_PID -urdth 1 > $PIDSTAT_LOG &
PIDSTAT_PID=$!

# Esperar a que termine Ansible
wait $ANSIBLE_PID

# Detener pidstat
kill $PIDSTAT_PID 2>/dev/null

echo "Ansible finalizó. Analizando datos..."


echo "Resumen guardado en $PIDSTAT_LOG"
