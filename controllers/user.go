package controllers

import (
	"log"
	"net/http"
	"time"
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

func (u *UserController) CreateAccount(c *gin.Context) {
	var user models.User

	// mengisi inputan user ke dalam variabel json
	if err := c.ShouldBindBodyWithJSON(&user); err != nil {
		log.Println(color.RedString("Error When Marshall Json Body : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"Error": err.Error()})
		return
	}

	// logika pengecekan apakah sebuah user memiliki email yang sama
	isEmailExist := u.db.Where("email = ?", user.Email).First(&user).RowsAffected != 0

	if isEmailExist {
		log.Println("This Email Already Have Account : ")
		c.JSON(http.StatusInternalServerError, gin.H{"Error": "This Email Already Have an account "})
		return
	}

	// Mengubah password menjadi lebih kompleks dengan cara hashing
	hashedPass, err := bcrypt.GenerateFromPassword([]byte(user.Password), 16)

	if err != nil {
		log.Println(color.RedString("Failed When Generating hashed Password : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"Error": err.Error()})
		return
	}

	// masukkan hasil hashed password
	user.Password = string(hashedPass)
	// Membuat sebuah role Akun
	user.Role = "Employee"

	// Memasukan record ke database
	if err := u.db.Create(&user).Error; err != nil {
		log.Println(color.RedString("Error when Creating an Account : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"Error": err.Error()})
		return
	}

	//Berikan Response Jika berhasil dilakukan
	c.JSON(http.StatusOK, user)
}

func (u *UserController) DeleteAccount(c *gin.Context) {
	// mengambil nilai dari id di url /users/:id dia akan mengambil nilai dari
	// :id
	id := c.Param("id")
	// digunakan untuk mengecek apakah akun dengan id sekian ada?
	err := u.db.Where("id = ?", id).Take(&models.User{}).Error

	if err != nil {
		log.Println(color.RedString("Account Didnt Exist"))
		c.JSON(http.StatusNotFound, gin.H{"Error": "Account Didnt Exist"})
		return
	}

	// Delete Account dengan id sekian
	if err := u.db.Delete(&models.User{}, id).Error; err != nil {
		log.Println(color.RedString("Error When Deleteing Account : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"Error": err.Error()})
		return
	}

	// Berikan Response Berhasil jika selesaip
	c.JSON(http.StatusOK, "Completed Delete Account")
}

func (u *UserController) GetEmployee(c *gin.Context) {
	// Logika dari mengambil value nya itu adalah array of struct
	// jadi di dalam array ada sebuah struct models.User maka dari itu
	// kita membuat sebuah variabel array models.User karna kita ingin mengambil
	// lebih dari satu akun employee
	var users []models.User

	// Mengambil Semua akun yang role nya employee dan belum ada catatan deleted_at
	// namun kita hanya akan mengambil nama dan juga id dari akun tersebut
	// time.Time{} == null / nil
	err := u.db.Select("id,name").
		Where(models.User{Role: "Employee", DeletedAt: time.Time{}}).
		Find(&users).Error

	if err != nil {
		log.Println(color.RedString("Error When GET all employee : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"Error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}
