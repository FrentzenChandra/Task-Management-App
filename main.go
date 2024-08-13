package main

import (
	"log"
	"tusk/config"
	"tusk/controllers"
	"tusk/models"

	"github.com/fatih/color"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func UserRouterSetup(router *gin.Engine, db *gorm.DB) {
	userController := controllers.NewUserController(db)

	router.POST("/users/login", userController.Login)
}

func main() {

	//Memangil function konek database dari folder/package tusk/config
	db := config.DatabaseConnection()

	// Ini berguna untuk meng migrate database
	err := db.AutoMigrate(&models.User{}, &models.Task{})
	if err != nil {
		log.Println(color.RedString("Gagal Melakukan Migrate : " + err.Error()))
	}

	// Berguna untuk menginisiasi router dengan gin
	// mengembalikan sebuah *gin.Engine yang disimpan pada variabel router
	router := gin.Default()

	// mengsetup sebuah url /ping yang jika diakses /ping nya
	// akan menunjukan isi json yang berisi data json yang berisi
	// message : pong
	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	UserRouterSetup(router , db)

	// ini berguna jika kita mengakses 192.168.18.5:9090/attachments memiliki isi yang sama dengan
	// ./attachemts yang dimana berada pada folder kita sekarang
	router.Static("/attachments", "./attachments")

	// berjalan di localhost:9090 ini dapat diakses pada chrome kalian
	router.Run("192.168.18.5:9090")
}
