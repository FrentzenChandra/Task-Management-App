package controllers

import (
	"log"
	"net/http"
	"tusk/models"

	"github.com/fatih/color"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserController struct {
	db *gorm.DB
}

func NewUserController(db *gorm.DB) *UserController {
	// berguna untuk setup
	return &UserController{db: db}
}

func (u *UserController) Login(c *gin.Context) {
	// Buat sebuah variabel dengan tipe struct user
	var user models.User

	// Hasil dari form yang diisi oleh user / pengguna yang berupa json dimasukan ke dalam
	// Variabel user dengan error handling nya sekaligus
	if err := c.ShouldBindBodyWithJSON(&user); err != nil {
		log.Println(color.RedString("Error Parsing Json Into Struct Login : " + err.Error()))

		// ini pengembalian response json yang berisikan kode status bersama dengan isi json nya
		// dalam kasus ini kode status internal server error dan juga berisi json error
		c.JSON(http.StatusInternalServerError, gin.H{"Error": err.Error()})
		return
	}
	// Mengisi Password Inputan user
	passwordInput := user.Password

	// logika nya jika kita login pada sebuah aplikasi, user hanya akan memberikan sebuah input
	// email dan juga password nah kita memerlukan lebih dari itu jadi yang kita lakukan adalah
	// mengambil sebuah data yang memiliki email yang sama dan timpa di variabel user
	// lalu kembalikan error jika ada
	// jadi jika kita artikan dalam perintah ini adalah gorm tolong carikan saya sebuah
	// data yang memiliki email yang sama dengan user.Email lalu masukan ke dalam variabel user
	// jika ada error kembalikan
	if err := u.db.Where("email = ?", user.Email).Take(&user).Error; err != nil {
		log.Println(color.RedString("Error There no User With Such email : " + err.Error()))

		c.JSON(http.StatusInternalServerError, gin.H{"Error": "Email Atau Password Gagal Mohon Dicoba kembali"})
		return
	}

	// nah di sini berguna untuk mengbandingkan apakah password inputan user dan password yang kita ambil
	// bedasarkan database dibandingkan oleh golang apakah sama ? jika berbeda maka kembalikan response error
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(passwordInput)); err != nil {
		log.Println(color.RedString("Error When Comparing Password : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"Error": "Email Atau Password Gagal Mohon Dicoba kembali"})
		return
	}

	// kembalikan response data user dan status kode berjalan dengan lancar
	c.JSON(http.StatusOK, user)
}
