package main

import (
	"fmt"

	"github.com/go-redis/redis"
)

// TODO make channel configurable
const defaultChannel = "mychannel"

type config struct {
	client *redis.Client
}

func main() {
	redisdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379", // TODO make it configurable
		Password: "", DB: 0,
	})

	_, err := redisdb.Ping().Result()
	if err != nil {
		panic(err)
	}

	c := config{client: redisdb}

	err = c.ProcessMessages(defaultChannel)
	if err != nil {
		panic(err)
	}
}

// Publish a message
func (c config) PublishMessage(msg string) error {
	err := c.client.Publish(defaultChannel, "hello").Err()
	if err != nil {
		return err
	}
	return nil
}

func (c config) ProcessMessages(channel string) error {
	pubsub := c.client.Subscribe(channel)
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
