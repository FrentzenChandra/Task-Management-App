package controllers

import (
	"log"
	"net/http"
	"os"
	"strconv"
	"tusk/models"

	"github.com/fatih/color"
	"github.com/gin-gonic/gin"
	"github.com/thanhpk/randstr"
	"gorm.io/gorm"
)

type taskController struct {
	db *gorm.DB
}

func NewTaskController(db *gorm.DB) *taskController {
	return &taskController{db: db}
}

func (t *taskController) Create(c *gin.Context) {
	var task models.Task

	// Mengambil JSON Inputan User
	if err := c.ShouldBindBodyWithJSON(&task); err != nil {
		log.Println(color.RedString("Error Json marhsal Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Membuat data ke database
	if err := t.db.Create(&task).Error; err != nil {
		log.Println(color.RedString("Error When creating task data : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Berikan Response
	c.JSON(http.StatusOK, &task)
}

func (t *taskController) Delete(c *gin.Context) {
	var task models.Task
	// Menagambil path param id
	idTask := c.Param("id")

	// Mengambil data sekaligus mengecek apakah data ada? atau tidak
	if err := t.db.Where("id = ?", idTask).Take(&task).Error; err != nil {
		log.Println(color.RedString("Error When getting task data : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Task Not Found"})
		return
	}

	// Mendeteksi apakah ada sebuah attachments seperti foto dll dalam data
	if task.Attachment != "" {
		// Jika ada maka hapus file tersebut yang berlokasi /attachments + nama dari file
		if err := os.Remove("./attachments/" + task.Attachment); err != nil {
			log.Println(color.RedString("Error When deleting attachment file : " + err.Error()))
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	// Menghapus data yang memiliki id sekian
	if err := t.db.Where("id = ?", idTask).Delete(&models.Task{}).Error; err != nil {
		log.Println(color.RedString("Error When deleting task data : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Response jika berhasilp
	c.JSON(http.StatusOK, "Delete Task Complete")

}

func (t *taskController) SubmitTask(c *gin.Context) {
	// Mengambil Data Path Param
	id := c.Param("id")

	var task *models.Task

	// Mengambil data yang dikirim menggunakan form
	// dari inputan user
	submitDate := c.PostForm("submitDate")
	file, err := c.FormFile("attachment")

	if err != nil {
		log.Println(color.RedString("Error When Get FormFile data : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Mengecek Terlebih dahulu apakah ada data yang memiliki id ini?
	if err := t.db.Where("id = ?", id).Take(&task).Error; err != nil {
		log.Println(color.RedString("Error Task Not found : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Not Found"})
		return
	}

	// Lalu mengecek apakah data tersebut memiliki attachments / file / gambar
	if task.Attachment != "" {
		// Jika ada maka kita hapus
		if err := os.Remove("./attachments/" + task.Attachment); err != nil {
			log.Println(color.RedString("Error When deleting attachment file : " + err.Error()))
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	// import "github.com/thanhpk/randstr"
	// Ini berguna untuk memberi nama yang unik kepada file karna logika nya
	// jika kita menyimpan suatu file di lokasi yang sama pasti akan ada sebuah file
	// yang memiliki nama yang sama
	hashedId := randstr.String(task.Id)

	// Mengupload file menggunakan gin yang meminta paramter file dan juga tujuan lokasi di upload
	if err := c.SaveUploadedFile(file, "./attachments/"+string(hashedId)+file.Filename); err != nil {
		log.Println(color.RedString("Error When Save Uploaded File : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Mengupdates data / mengubah data
	err = t.db.Where("id = ?", id).Updates(models.Task{
		Status:     "Review",
		SubmitDate: submitDate,
		Attachment: string(hashedId) + file.Filename,
	}).Error

	if err != nil {
		log.Println(color.RedString("Error When Update Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Response jika berhasil
	c.JSON(http.StatusOK, "Task Submit Complete")
}

func (t *taskController) RejectTask(c *gin.Context) {
	// Mengambil Data Path Param
	id := c.Param("id")

	var task models.Task

	// Mengambil form inputan user
	reason := c.PostForm("reason")
	rejectDate := c.PostForm("rejectedDate")

	// Mengecek Terlebih dahulu apakah ada data yang memiliki id ini?
	if err := t.db.Where("id = ?", id).Take(&task).Error; err != nil {
		log.Println(color.RedString("Error Task Not found : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Not Found"})
		return
	}

	// mengupdate data
	err := t.db.Where("id = ?", id).Updates(models.Task{
		Status:       "Rejected",
		Reason:       reason,
		RejectedDate: rejectDate,
	}).Error

	if err != nil {
		log.Println(color.RedString("Error When Update Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Rejected")

}

func (t *taskController) Fix(c *gin.Context) {
	// Mengambil Data Path Param
	id := c.Param("id")

	var task models.Task

	// Mengambil form inputan user
	reason := c.PostForm("revision")
	reasonInt, err := strconv.Atoi(reason)

	if err != nil {
		log.Println(color.RedString("Error When Parse Revision : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Mengecek Terlebih dahulu apakah ada data yang memiliki id ini?
	if err := t.db.Where("id = ?", id).Take(&task).Error; err != nil {
		log.Println(color.RedString("Error Task Not found : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Not Found"})
		return
	}

	// mengupdate data
	err = t.db.Where("id = ?", id).Updates(models.Task{
		Status:   "Queue",
		Revision: reasonInt,
	}).Error

	if err != nil {
		log.Println(color.RedString("Error When Update Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Rejected")

}

func (t *taskController) Approve(c *gin.Context) {
	// Mengambil Data Path Param
	id := c.Param("id")

	var task models.Task

	// Mengambil form inputan user
	approvedDate := c.PostForm("approvedDate")

	// Mengecek Terlebih dahulu apakah ada data yang memiliki id ini?
	if err := t.db.Where("id = ?", id).Take(&task).Error; err != nil {
		log.Println(color.RedString("Error Task Not found : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Not Found"})
		return
	}

	// mengupdate data
	err := t.db.Where("id = ?", id).Updates(models.Task{
		Status:       "Approved",
		ApprovedDate: approvedDate,
	}).Error

	if err != nil {
		log.Println(color.RedString("Error When Update Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Approved")

}

func (t *taskController) FindById(c *gin.Context) {
	// Mengambil Data Path Param
	id := c.Param("id")

	var task models.Task

	// Mengecek Terlebih dahulu apakah ada data yang memiliki id ini?
	if err := t.db.Where("id = ?", id).Take(&models.Task{}).Error; err != nil {
		log.Println(color.RedString("Error Task Not found : " + err.Error()))
		c.JSON(http.StatusNotFound, gin.H{"error": "Not Found"})
		return
	}

	// mengambil data task dan juga mengisi data yang memiliki foreign key
	// dalam hal ini adalah User paramter preload bergantung kepada
	// models
	err := t.db.Preload("User").Find(&task, id).Error

	if err != nil {
		log.Println(color.RedString("Error When Update Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, task)

}

func (t *taskController) NeedToBeReview(c *gin.Context) {
	var tasks []models.Task

	// Mengambil data yang memiliki status review dan
	// Di susun bedasarkan yang paling baru ke yang paling lama
	err := t.db.Preload("User").
		Where("status=?", "Review").
		Order("submit_date ASC").
		Find(&tasks).Error

	if err != nil {
		log.Println(color.RedString("Error When Find Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)

}

func (t *taskController) ProgressTasks(c *gin.Context) {

	var tasks []models.Task
	userId := c.Param("userId")

	//Mengambil data task bedasarkan
	// status yang bukan queue dan userid yang sama  atau  revisi bukan 0 dan userid yang sama
	err := t.db.Preload("User").
		Where("(status != ? AND user_id=?) OR (revision != ? AND user_id = ?)",
			"Queue",
			userId,
			0,
			userId).
		Order("updated_at DESC").
		Find(&tasks).Error

	if err != nil {
		log.Println(color.RedString("Error When Find Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)

}

func (t *taskController) Statistic(c *gin.Context) {

	userId := c.Param("userId")
	stat := []map[string]interface{}{}

	// Mengambil berapa banyak data yang memiliki nilai yang sama
	// dan total dari banyak data tersebut dimaukkan ke dalam variabel
	// total  dan di group bedasarkan status
	err := t.db.Model(models.Task{}).
		Select("status, count(status) as total").
		Where("user_id=?", userId).
		Group("status").
		Find(&stat).Error

	if err != nil {
		log.Println(color.RedString("Error When Find Task Statistic : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stat)

}

func (t *taskController) FindByUserAndStatus(c *gin.Context) {

	var tasks []models.Task
	userId := c.Param("userId")
	Status := c.Param("status")

	// Mengambil data bedasrakan status dan user id sekian 
	err := t.db.Preload("User").
		Where("(status = ? AND user_id=?)",
			Status,
			userId).
		Find(&tasks).Error

	if err != nil {
		log.Println(color.RedString("Error When Find Task : " + err.Error()))
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, tasks)

}
