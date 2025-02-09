#Script to save as PDF files the maps produced by A8bis_carto_time.R

ggsave(plot2_V_1,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t1.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale = 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_V_2,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t2.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_V_3,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t3.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_V_4,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t4.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_1,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t1.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale = 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_2,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t2.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_3,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t3.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_4,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t4.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_W_1,
	      path = "Graphs",
							filename = paste(my_var,"map_W_t1.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale = 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_W_2,
	      path = "Graphs",
							filename = paste(my_var,"map_W_t2.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)


ggsave(plot2_W_4,
	      path = "Graphs",
							filename = paste(my_var,"map_W_t4.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)


ggsave(plot2_W_3,
	      path = "Graphs",
							filename = paste(my_var,"map_W_t3.pdf"),
							width = 25,
						 height = 19.5,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_V_t1_t2,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t1-t2.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_V_t3_t4,
	      path = "Graphs",
							filename = paste(my_var,"map_V_t3-t4.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_W_t1_t2,
	      path = "Graphs",
							filename = paste(my_var,"map_elision_weight_t1-t2.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_W_t3_t4,
	      path = "Graphs",
							filename = paste(my_var,"map_elision_weight_t3-t4.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_t1_t2,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t1-t2.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)

ggsave(plot2_C_t3_t4,
	      path = "Graphs",
							filename = paste(my_var,"map_C_t3-t4.pdf"),
							width = 25,
						 height = 39,
						 units = "cm",
						 scale= 1,
						 dpi = "retina",
							device = cairo_pdf)
