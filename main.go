package main

import (
	"flag"
	"fmt"

	"github.com/BurntSushi/toml"
	"github.com/go-redis/redis"
)

type config struct {
	Channel string      `toml:"channel"`
	Redis   redisConfig `toml:"redis"`
	client  *redis.Client
}

type redisConfig struct {
	Hostname string `toml:"hostname"`
	Port     string `toml:"port"`
}

func main() {
	// Toml config
	var configToml string
	flag.StringVar(&configToml, "c", "", "path to a config.toml")
	flag.Parse()
	if configToml == "" {
		panic("missing config.toml")
	}

	// Read config
	var c config
	fmt.Printf("Loading config file %s\n", configToml)
	if _, err := toml.DecodeFile(configToml, &c); err != nil {
		panic(err)
	}

	// Create redis client
	redisdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("localhost:%s", c.Redis.Port),
		Password: "", DB: 0,
	})

	if _, err := redisdb.Ping().Result(); err != nil {
		panic(err)
	}
	c.client = redisdb

	if err := c.ProcessMessages(); err != nil {
		panic(err)
	}
}

// Publish a message
func (c config) PublishMessage(msg string) error {
	err := c.client.Publish(c.Channel, "hello").Err()
	if err != nil {
		return err
	}
	return nil
}

func (c config) ProcessMessages() error {
	pubsub := c.client.Subscribe(c.Channel)
	_, err := pubsub.Receive()
	if err != nil {
		return err
	}
	defer pubsub.Close()

	// Maybe store the channel in the config?
	ch := pubsub.Channel()

	// Consume messages
	for {
		select {
		case msg := <-ch:
			fmt.Printf("Received message from channel '%s'. message:'%s'\n", msg.Channel, msg.Payload)
		}
	}

	return nil
}
