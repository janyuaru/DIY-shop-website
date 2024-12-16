package main

import (
	"context"
	"ecommercestore/internal/config"
	"ecommercestore/internal/handlers"
	"ecommercestore/internal/product"
	"log"

	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func TimeoutMiddleware(timeout time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
		defer cancel()

		c.Request = c.Request.WithContext(ctx)
		c.Next()
	}
}

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	db, err := product.NewPostgresDatabase(cfg.GetConnectionString())
	if err != nil {
		log.Printf("Failed to connect to database: %v", err)
	}
	if db != nil {
		defer db.Close()
	}

	store := product.NewStore(db)
	h := handlers.NewProductHandlers(store)

	go func() {
		for {
			time.Sleep(10 * time.Second)
			if err := db.Ping(); err != nil {
				log.Printf("Database connection lost: %v", err)
				// พยายามเชื่อมต่อใหม่
				if reconnErr := db.Reconnect(cfg.GetConnectionString()); reconnErr != nil {
					log.Printf("Failed to reconnect: %v", reconnErr)
				} else {
					log.Printf("Successfully reconnected to the database")
				}
			}
		}
	}()

	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()

	configCors := cors.Config{
		AllowOrigins:     []string{"http://localhost:3000", "http://localhost:4000"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}

	r.Use(cors.New(configCors))

	r.Use(TimeoutMiddleware(5 * time.Second))

	r.GET("/health", h.HealthCheck)

	v1 := r.Group("/api/v1")
	{
		products := v1.Group("/products")
		{
			products.GET("", h.GetProducts)
			products.GET("/:id", h.GetProduct)

			images := products.Group("/:id/images")
			{
				images.GET("", h.GetProductImages)
			}
		}

		shops := v1.Group("/shops")
		{
			shops.GET("/:id", h.GetShops)
		}

		categories := v1.Group("/categories")
		{
			categories.GET("", h.GetCategories)
			categories.GET("/:id", h.GetprodCategory)
		}
	}

	if err := r.Run(":" + cfg.AppPort); err != nil {
		log.Printf("Failed to run server: %v", err)
	}
}
