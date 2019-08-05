package main

import (
	"fmt"

	"github.com/go-redis/redis"
)

func main() {
	redisdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", DB: 0,
	})

	pong, err := redisdb.Ping().Result()
	fmt.Println(pong, err)
}
