#!/bin/bash

#Instalación servicio DHCP
clear
if [ -f /etc/dhcp/dhcpd.conf ]
then echo dhcp está instalado.
else apt install isc-dhcp-server -y
fi
clear

echo ---- Nombre tarjeta de red ----
read var
sed -i "s/INTERFACESv4=\"*\"/INTERFACESv4=\"$var\"/" /etc/default/isc-dhcp-server

#Configuración de las redes
cont=0
echo ---- ¿Cuántas redes va a configurar? ----
read res
while [ $cont -ne $res ]
do
while true;
do
echo ---- Introduce la IP ----
read ip
        for (( i=1; i<=4; i++))
        do
                var1=$( echo $ip | cut -d . -f$i)
                if [ $var1 -gt 255 ] || [ -z $var1 ]
                then
                        echo La IP no está correctamente formada
                        break
                elif [ $i = 4 ]
                then
                        confirmador=1
                fi
        done
        if [ $confirmador = 1 ]
        then
                break
        fi
done
echo ---- Introduce máscara de red ----
read subnet
echo ---- Rango ----
echo ---- x.x.x.x x.x.x.x ----
read rango
echo ---- Gateway ----
echo ---- x.x.x.x ----
read gateway
echo ---- DNS ----
echo ---- x.x.x.x, x.x.x.x ----
read dominio
echo "subnet $ip netmask $subnet {

        range $rango;
        option router $gateway;
        option domain-name-servers $dominio;" >> /etc/dhcp/dhcpd.conf
((cont++))
done
#Reservas de la red
cont1=0
echo ---- ¿Cuántas reservas posee esta red? ----
read res1
while [ $cont1 -ne $res1 ]
do
echo ---- MAC del dispositivo de reserva ----
echo ---- xx:xx:xx:xx:xx:xx ----
read mac
echo ---- Nombre de la reserva ----
read reserva
echo ---- IP a reservar ----
read resip
echo " host $reserva {
        hardware ethernet $mac;
        fixed-address $resip;
}
" >> /etc/dhcp/dhcpd.conf
((cont1++))
done
echo "}" >> /etc/dhcp/dhcpd.conf



systemctl restart isc-dhcp-server
