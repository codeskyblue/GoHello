package hi

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"time"
)

var c chan int

func init() {
	c = make(chan int)
	rand.Seed(time.Now().Unix())
	go func() {
		for {
			c <- rand.Int()
		}
	}()
}
func Hello(name string) string {
	fmt.Printf("Hello, %s!\n", name)
	return "(Go)World"
}

func RandInt() int {
	return <-c
}

func MyIP() string {
	resp, err := http.Get("http://ifconfig.mt.nie.netease.com/all.json")
	if err != nil {
		return err.Error()
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err.Error()
	}
	return string(body)
}
