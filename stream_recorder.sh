#!/bin/bash

source .env

#trap cleanup SIGINT

notify-send "Gravação de camera iniciada."

log_file="$LOGS_DIR/" + $(date +"%Y-%m-%d %H:%M:%S.log")
touch $log_file
segment_time=3600
attempt_counter=0
max_attempts=3

# Define o comando FFmpeg
ffmpeg_command="ffmpeg -i rtsp://$RTSP_USER:$RTSP_PASSWORD@$RTSP_IP:$RTSP_PORT/onvif1 -c:v copy -c:a pcm_alaw -f segment -segment_time $segment_time -strftime 1 \"$RECORDS_DIR/%Y-%m-%d %H:%M:%S.avi\""

# Loop até atingir o número máximo de tentativas
while [ $attempt_counter -lt $max_attempts ]; do
  # Executa o comando FFmpeg e redireciona a saída para o log
  eval $ffmpeg_command >> "$log_file" 2>&1
  
  # Verifica se o comando falhou
  if [ $? -ne 0 ]; then
    attempt_counter=$((attempt_counter+1))
    echo "FFmpeg falhou. Tentativa $attempt_counter de $max_attempts." >> "$log_file"
    
    # Verifica se o número máximo de tentativas foi atingido
    if [ $attempt_counter -eq $max_attempts ]; then
      echo "Número máximo de tentativas atingido. Saindo..." >> "$log_file"
      break
    fi
    
    # Aguardando 5 segundos antes de tentar novamente
    sleep 5
  else
    # Sai do loop se o FFmpeg terminar normalmente (sem falhas)
    echo "FFmpeg executado com sucesso." >> "$log_file"
    break
  fi
done

notify-send "A gravação terminou."

