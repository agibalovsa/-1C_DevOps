. "../../../common_context/build/tools.ps1"

Set-Vars-From-File ".env"

Create-Docker-Volume "${OC_SRVINFO_VOL}" "${OC_SRVINFO_MOUNT_PATH}"
Create-Docker-Volume "${OC_LOG_VOL}"     "${OC_LOG_MOUNT_PATH}"
Create-Docker-Volume "${OC_CONF_VOL}"    "${OC_CONF_MOUNT_PATH}"
Create-Docker-Volume "${OC_LIC_VOL}"     "${OC_LIC_MOUNT_PATH}"