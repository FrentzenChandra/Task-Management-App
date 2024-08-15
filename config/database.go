package config

import (
	"errors"
	"log"
	"os"
	"time"
	"tusk/models"

	// Jika ada error di sini Silakan Di go get < package yang error >

	"github.com/fatih/color"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func DatabaseConnection() *gorm.DB {
	// ini berguna untuk kodingan mencari env || go get "github.com/joho/godotenv"
	err := godotenv.Load(".env")

	if err != nil {
		log.Fatal(color.RedString("Error loading .env file") + err.Error())
		return nil
	}

	// ambil isi env yang memiliki nama DB_NAME
	dbName := os.Getenv("DB_NAME")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")

	// String untuk menentukan tujuan koneksi dari database
	dsn := dbUser + ":" + dbPass + "@tcp(" + dbHost + ":" + dbPort + ")/" + dbName + "?charset=utf8mb4&parseTime=True&loc=Local"

	// Koneksikan Database
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})

	//Error Handling jangan lupa Jika error Print di terminal "Error saat Menghubungkan ke database " + error yang dikembalikan sebelumnya
	// go get "github.com/fatih/color"
	if err != nil {
		log.Fatal(color.RedString("Error Saat Menghubungkan Ke database") + err.Error())
		return nil
	}

	log.Println(color.GreenString("Database Berhasil Dikoneksikan!!!"))
	return db
}

func CreateOwnerAccount(db *gorm.DB) error {
	// Menghashing Password yang isi nya "Password" || go get "golang.org/x/crypto/bcrypt"
	bytes, err := bcrypt.GenerateFromPassword([]byte("Password"), 14)

	if err != nil {
		log.Println(color.RedString("Error Pada Saat Hashing Password") + err.Error())
		return errors.New("Error Pada Saat Hashing Password")
	}
	// Membuat data struct dengan isi sebagai berikut
	owner := &models.User{
		Role:      "Admin",
		Name:      "Acen",
		Email:     "frentzenpp@gmail.com",
		Password:  string(bytes),
		CreatedAt: time.Now(),
		UpdatedAt:  time.Now(),
	}

	//Cek Logika Terlebih dahulu Jika ada sebuah User dengan email yang sama maka
	// Cancel Pembuatan data dalam database

	if db.Where("email=?", owner.Email).First(&owner).RowsAffected == 0 {
		db.Create(&owner)
	} else {
		log.Println(color.RedString("Owner Sudah Ada"))
		return errors.New("Owner Sudah Ada")
	}

	return nil
}
