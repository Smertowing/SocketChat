package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"strings"
	"sync"
  "bytes"
)

//UGHHHHH ...
var (
	CHOST = "192.168.1.104"
	CPORT = "55556"
	CNET  = "tcp"
)

//MSG is used in transporting individual messages
type MSG struct {
	username string
	msg      string
	isLast   bool

	conn *net.TCPConn
}

//Conns contains all connections
type Conns struct {
	conns map[string]*net.TCPConn
	sync.RWMutex
}

//User contains username
type User struct {
	Username string
}

//New ...
func (c *Conns) New(key string, conn *net.TCPConn) bool {
	c.Lock()
	defer c.Unlock()

	if _, ok := c.conns[key]; !ok {
		c.conns[key] = conn
		return true
	}
	return false
}

//Delete ...
func (c *Conns) Delete(key string) bool {
	c.Lock()
	defer c.Unlock()

	if _, ok := c.conns[key]; ok {
		delete(c.conns, key)
		return true
	}
	return false
}

//Read ...
func (c *Conns) Read(key string) *net.TCPConn {
	c.RLock()
	defer c.RUnlock()

	if conn, ok := c.conns[key]; ok {
		return conn
	}

	return nil
}

func (c *Conns) broadcast(messages chan *MSG) {
	//Loop continually sending messages
	for {
		msg := <-messages
		//If user left, remove from conn pool
		if msg.isLast {
		  c.Delete(msg.conn.RemoteAddr().String())
      continue
		}

		for _, conn := range c.conns {
			//Write user message to group
      fmt.Println(msg.msg + "\n")
			_, err := conn.Write([]byte(msg.msg))
			if err != nil {
        c.Delete(msg.conn.RemoteAddr().String())
			}
		}
	}
}

func initUser(conn *net.TCPConn) *User {
	//Read data from connection
	buf := make([]byte, 2048)
	_, err := conn.Read(buf)
	if err != nil {
		fmt.Println("Error reading:", err.Error())
		return nil
	}

  buf = bytes.Trim(buf, "\x00")

	data := string(buf)
	if data == "" {
		return nil
	}

	info := strings.Split(data, ":")
	if len(info) < 2 || info[0] != "iam" {
		return nil
	}

	return &User{Username: info[1]}
}

func main() {
	//Create addr
	addr, err := net.ResolveTCPAddr(CNET, CHOST+":"+CPORT)
	handleError(err)

	//Create listener
	tcpListener, err := net.ListenTCP(CNET, addr)
	handleError(err)
	defer tcpListener.Close()

	//Create broadcaster
	var broadcaster = make(chan *MSG, 1)
	defer close(broadcaster)
	c := &Conns{
		conns: make(map[string]*net.TCPConn),
	}
	go c.broadcast(broadcaster)

	fmt.Println("Listening on " + CHOST + ":" + CPORT)
	for {
		// Listen for an incoming connection.
		conn, err := tcpListener.AcceptTCP()
		handleError(err)
		c.New(conn.RemoteAddr().String(), conn)

		// Handle connections in a new goroutine.
		go handleRequest(conn, broadcaster)
	}

	return
}

func handleRequest(conn *net.TCPConn, messages chan *MSG) {
	defer conn.Close()

	//Get user info from client
	user := initUser(conn)
	if user == nil {
		return
	}

	msg := &MSG{
		username: user.Username,
		msg:      fmt.Sprintf("%s has joined\n", user.Username),
		conn:     conn,
		isLast:   false,
	}
	messages <- msg

	for {
		//Read data from connection
		buf := make([]byte, 2048)
		_, err := conn.Read(buf)
		if err != nil {
			fmt.Println("Error reading:", err.Error())
			//Client closed, alert other users
      msg := &MSG{
    		username: user.Username,
    		msg:      "",
    		conn:     conn,
    		isLast:   true,
    	}
	    messages <- msg

			return
		}

    buf = bytes.Trim(buf, "\x00")

		//Check if msg string has content and that it is a msg type
		content := string(buf)
		if content == "" {
			continue
		}

		info := strings.Split(content, ":")
		if len(info) < 2 || info[0] != "msg" {
			continue
		}

		msg := &MSG{
			username: user.Username,
      msg:      user.Username + ":" + info[1],
			conn:     conn,


			isLast:   false,
		}
		messages <- msg
	}

	return
}

func handleError(err error) {
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
}
