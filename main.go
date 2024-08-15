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

	router.GET("/users/Employee", userController.GetEmployee)
	router.POST("/users/login", userController.Login)
	router.POST("/users", userController.CreateAccount)
	// Perhatikan router.Delete , router.Post dll itu adalah method dari routing
	router.DELETE("/users/:id", userController.DeleteAccount)
}

func TaskRouterSetup(router *gin.Engine, db *gorm.DB) {
	taskController := controllers.NewTaskController(db)

	router.POST("/tasks", taskController.Create)

	router.DELETE("/tasks/:id", taskController.Delete)

	router.PATCH("/tasks/:id/submit", taskController.SubmitTask)
	router.PATCH("/tasks/:id/reject", taskController.RejectTask)
	router.PATCH("/tasks/:id/fix", taskController.Fix)
	router.PATCH("/tasks/:id/approvep", taskController.Approve)

	router.GET("/tasks/:id", taskController.FindById)
	router.GET("/tasks/review/asc", taskController.NeedToBeReview)
	router.GET("/tasks/progress/:userId", taskController.ProgressTasks)
	router.GET("/tasks/stat/:userId", taskController.Statistic)
	router.GET("/tasks/user/:userId/:status", taskController.FindByUserAndStatus)

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

	UserRouterSetup(router, db)
	TaskRouterSetup(router, db)

	// ini berguna jika kita mengakses 192.168.18.5:9090/attachments memiliki isi yang sama dengan
	// ./attachemts yang dimana berada pada folder kita sekarang
	router.Static("/attachments", "./attachments")

	// berjalan di localhost:9090 ini dapat diakses pada chrome kalian
	router.Run("192.168.18.5:9090")
}
