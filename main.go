package main

import (
	"fmt"
	"github.com/shirou/gopsutil/cpu"
	"github.com/shirou/gopsutil/mem"
	"log"
	"math"
	"net"
	"net/http"
	"os"
	"syscall"
)

const PORT = "8012"

func humanReadableSIByte(byte uint64) string {
	return humanReadableByte(byte, true)
}

func humanReadableByte(byte uint64, si bool) string { //SI: standardisation
	var unit = 1024
	if si {
		unit = 1000
	}
	if byte < uint64(unit) {
		return fmt.Sprintf("%dB", byte)
	}
	exp := int(math.Log(float64(byte)) / math.Log(float64(unit)))
	pre := "KMGTPE"[(exp - 1):exp]
	if !si {
		pre += "i"
	}
	return fmt.Sprintf("%.1f %sB", float64(byte)/math.Pow(float64(unit), float64(exp)), pre)
}

func getIP() string {

	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return err.Error()
	}
	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				return ipnet.IP.String()
			}
		}
	}
	return "not set ip"
}

func getDiskInfo() string {
	var fs syscall.Statfs_t
	err := syscall.Statfs("/", &fs)
	if err != nil {
		return err.Error()
	}
	total := humanReadableSIByte(fs.Blocks * uint64(fs.Bsize))
	free := humanReadableSIByte(fs.Bfree * uint64(fs.Bsize))
	used := humanReadableSIByte((fs.Blocks - fs.Bfree) * uint64(fs.Bsize))
	return fmt.Sprintf("Total-%s, Free-%s, Used-%s ", total, free, used)
}

func getMem() string {
	v, _ := mem.VirtualMemory()
	return fmt.Sprintf("Total-%s, Free-%s, Used-%2.0f%%%%", humanReadableSIByte(v.Total), humanReadableSIByte(v.Free), v.UsedPercent)
}

func getCpuCores() int32 {
	v, _ := cpu.Info()
	return v[0].Cores
}

func main() {

	hostname, _ := os.Hostname()
	output := fmt.Sprintf("Hostname: %s\n      IP: %s\n    Disk: %s\n  Memery: %s\n     CPU: %d cores", hostname, getIP(), getDiskInfo(), getMem(), getCpuCores())

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("\n" + output)
		fmt.Fprintf(w, output)
	})

	log.Printf("Listening on: %s\n", PORT)
	log.Fatalln(http.ListenAndServe(":"+PORT, nil))
}
